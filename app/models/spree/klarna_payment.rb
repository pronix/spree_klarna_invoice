# encoding: utf-8

class Spree::KlarnaPayment < ActiveRecord::Base
  has_many :payments, as: :source

  validates :social_security_number, :firstname, :lastname, presence: true

  attr_accessible :firstname, :lastname, :social_security_number,
                  :invoice_number, :client_ip

  def actions
    %w{capture}
  end

  # format log messages
  def log_message(str)
    "\n----------- #{str} -----------\n"
  end

  # format and send message to debug
  def mes_debug(str)
    logger.debug log_message(str)
  end

  # format and send message to info
  def mes_info(str)
    logger.info log_message(str)
  end

  # Indicates whether its possible to capture the payment
  def can_capture?(payment)
    ['checkout', 'pending', 'processing'].include?(payment.state) &&
      payment.order.klarna_invoice_number.present?
  end

  # format error message for process
  def process_error_message(inv_num,payment)
    mes = 'KlarnaPayment.process! -> Order Exists in Klarna with no: '
    mes << inv_num.to_s
    mes << " | Order: #{payment.order.number} (#{payment.order.id})"
    logger.error log_message(mes)
  end

  def process!
    mes_debug('KlarnaPayment.process!')

    payment = self.payments.first
    inv_num = self.invoice_number

    if inv_num.blank?
      create_invoice(payment)
    else
      process_error_message(inv_num,payment)
    end

    if Spree::Config[:auto_capture] && inv_num.present?
      return capture(payment)
    end

    return ActiveMerchant::Billing::Response.new(true, 'Klarna Payment : Created invoice without capture', {})
  end

  # Activate action
  def capture(payment)
    mes_debug('KlarnaPayment.capture')
    pay_method = payment.payment_method
    logger.info "Country Code #{pay_method.preferred(:country_code)}"
    logger.info "Store Id #{pay_method.preferred(:store_id)}"
    logger.info "Store Secret #{pay_method.preferred(:store_secret)}"

    if payment.state == 'checkout' || payment.state == 'processing'
      payment.update_attribute(:state, 'pending')
    end

    begin
      activate_invoice(payment) if pay_method.preferred(:mode) != 'test' && pay_method.preferred(:activate_in_days) <= 0
      payment.complete!
      payment.order.update!
      ActiveMerchant::Billing::Response.new(true, 'Klarna Payment : Success', {})
    rescue ::Klarna::API::Errors::KlarnaServiceError => e
      payment.order.set_error e.error_message
      gateway_error("KlarnaPayment.process! >>> #{e.error_message}")
      ActiveMerchant::Billing::Response.new(false, 'Klarna Payment : Could not capture', {})
    end
  end

  private

  # Init Klarna instance
  def init_klarna(payment)
    @@klarna ||= setup_klarna(payment)
    payment_method = Spree::PaymentMethod::KlarnaInvoice.first
    @@klarna.timeout = payment_method.preferred(:timeout) unless payment_method.preferred(:timeout) <= 0
  end

  # Setup Klarna connection
  def setup_klarna(payment)
    mes_debug('KlarnaPayment.setup_klarna')
    require 'klarna'

    pay_method = payment.payment_method

    Klarna::setup do |config|
      config.mode = pay_method.preferred(:mode)
      config.country = pay_method.preferred(:country_code) # SE
      config.store_id = pay_method.preferred(:store_id) # 2029
      config.store_secret = pay_method.preferred(:store_secret) # '3FPNSzybArL6vOg'
      config.logging = pay_method.preferred(:logging)
      config.http_logging = pay_method.preferred(:http_logging)
    end

    begin
      return ::Klarna::API::Client.new(::Klarna.store_id, ::Klarna.store_secret)
    rescue ::Klarna::API::Errors::KlarnaCredentialsError => e
      payment.order.set_error e.error_message
      gateway_error(e.error_message)
    rescue ::Klarna::API::Errors::KlarnaServiceError => e
      payment.order.set_error e.error_message
      gateway_error(e.error_message)
    end
  end

  # Create Klarna invoice and send to
  def create_invoice(payment)
    mes_debug('KlarnaPayment.create_invoice')

    # Initialize Klarna connection
    init_klarna(payment)

    #ssn = "411028-8083" # Not approved
    #ssn = "410321-9202" # Approved

    ssn = self.social_security_number
    pay_method = payment.payment_method

    # Implement verification to Klarna to get secret
    sso_secret = @@klarna.send(:digest,
                               pay_method.preferred(:store_id),
                               ssn,
                               pay_method.preferred(:store_secret))

    mes_debug("SSO Secret #{sso_secret} for #{ssn}")
    order_items = []

    payment_amount = 0

    # FIXME why taxrate first ?
    default_tax_rate = Spree::TaxRate.find(1)

    # Add products
    payment.order.line_items.each do |item|
      prod = item.product
      mes_debug("Item: #{item.quantity}, #{prod.sku}, #{prod.name}, #{item.amount}")
      flags = {}
      if default_tax_rate.included_in_price
        flags[:INC_VAT] = ::Klarna::API::GOODS[:INC_VAT]
      end
      order_items << @@klarna.make_goods(item.quantity, prod.sku, prod.name, prod.price * 100.00, default_tax_rate.amount*100, nil, flags)

      if ! default_tax_rate.included_in_price
        item.product.price = item.product.price * (default_tax_rate.amount + 1)
      end

      payment_amount += item.product.price
    end

    payment.order.adjustments.eligible.each do |adjustment|
      next if (adjustment.originator_type == 'Spree::TaxRate') or (adjustment.amount === 0)

      flags = {}
      if default_tax_rate.included_in_price
        flags[:INC_VAT]     = ::Klarna::API::GOODS[:INC_VAT]
      end

      if adjustment.label == Spree.t(:invoice_fee)
        flags[:IS_HANDLING] = ::Klarna::API::GOODS[:IS_HANDLING]
      end

      if adjustment.originator_type == 'Spree::ShippingMethod'
        flags[:IS_SHIPMENT] = ::Klarna::API::GOODS[:IS_SHIPMENT]
      end

      amount = 100 * adjustment.amount
      order_items << @@klarna.make_goods(1, '', adjustment.label, amount, default_tax_rate.amount * 100, nil, flags)

      if ! default_tax_rate.included_in_price
        adjustment.amount = adjustment.amount * (default_tax_rate.amount + 1)
      end

      payment_amount += adjustment.amount
      mes_info("Order: #{payment.order.number} (#{payment.order.id}) | payment_amount: #{payment_amount}")
    end

    # Create address
    bill_addr =  payment.order.bill_address
    raise 'Require country iso like SE for Sweden' if bill_addr.country.iso.blank?
    address = @@klarna.make_address("", bill_addr.address1,
                                    bill_addr.zipcode.delete(' ').to_i,
                                    bill_addr.city, bill_addr.country.iso,
                                    bill_addr.phone, nil, payment.order.email)

    # Do transaction and create invoice in Klarna
    begin
      mes_debug('add_transaction')

      # shipping_cost = payment.order.ship_total * 100
      # shipping_cost = shipping_cost * (1 + Spree::TaxRate.default) if Spree::Config[:shipment_inc_vat]

      # Client IP
      client_ip = pay_method.preferred(:mode) == 'test' ? '85.230.98.196' : payment.source.client_ip

      # Set ready date
      activate_days = pay_method.preferred(:activate_in_days)
      ready_date = if activate_days > 0
        (DateTime.now.to_date + activate_days).to_s
      else
        nil
      end

      # Set flags
      flags = {}
      flags[:TEST_MODE] = true unless pay_method.preferred(:mode) == 'production'
      flags[:AUTO_ACTIVATE] = true if pay_method.preferred(:auto_activate)

      mes_debug("add_transaction - Ready date: #{ready_date}")
      mes_debug("add_transaction - Flags: #{flags}")
      mes_debug("add_transaction - Client IP: #{payment.source.client_ip}")

      invoice_no = @@klarna.add_transaction(
          "USER-#{payment.order.user_id}",                          # store_user_id,
          payment.order.number,                                     # order_id,
          order_items,                                              # articles,
          0,                                                        # shipping_fee,
          0,                                                        # handling_fee,
          :NORMAL,                                                  # shipment_type,
          ssn,                                                      # pno,
          (bill_addr.company.blank? ? bill_addr.firstname.encode('iso-8859-1') : bill_addr.company.encode('iso-8859-1')), # first_name,
          bill_addr.lastname.encode('iso-8859-1'), # last_name,
          address,                                                  # address,
          client_ip,                                                # client_ip,
          pay_method.preferred(:currency_code),         # currency,
          pay_method.preferred(:country_code),          # country,
          pay_method.preferred(:language_code),         # language,
          pay_method.preferred(:country_code),          # pno_encoding,
          nil,                                                      # pclass = nil,
          nil,                                                      # annual_salary = nil,
          nil,                                                      # password = nil,
          ready_date,                                               # ready_date = nil,
          nil,                                                      # comment = nil,
          nil,                                                      # rand_string = nil,
          flags)                                                    # flags = nil

      mes_info("Order: #{payment.order.number} (#{payment.order.id}) | Invoice: #{invoice_no}")
      mes_info("Order: #{payment.order.number} (#{payment.order.id}) | payment_amount: #{payment_amount}")

      self.update_attribute(:invoice_number, invoice_no)
      payment.update_attribute(:amount, payment_amount)

    rescue ::Klarna::API::Errors::KlarnaServiceError => e
      payment.order.set_error e.error_message
      gateway_error(e.error_message)
    end
  end

  # raise missing invoice nubmer
  def raise_missing_invoice
    if self.invoice_number.blank?
      raise Spree::Core::GatewayError.new(Spree.t(:missing_invoice_number))
    end
  end

  # Active Klarna Invoice
  def activate_invoice(payment)
    mes_debug('KlarnaPayment.activate_invoice')
    init_klarna(payment)
    raise_missing_invoice

    @@klarna.activate_invoice(self.invoice_number)
    send_invoice(payment)
  end

  def send_invoice(payment)
    mes_debug('KlarnaPayment.send_invoice')
    init_klarna(payment)
    raise_missing_invoice

    if pay_method.preferred(:email_invoice)
      mes_info('KlarnaPayment.send_invoice : Email')
      @@klarna.email_invoice(self.invoice_number)
    end

    if pay_method.preferred(:send_invoice)
      mes_info('KlarnaPayment.send_invoice : Post')
      @@klarna.send_invoice(self.invoice_number)
    end
  end

  def gateway_error(text)
    msg = "#{text}"
    logger.error("KlarnaInvoice >>> #{msg}")
    raise Spree::Core::GatewayError.new(msg)
  end
end

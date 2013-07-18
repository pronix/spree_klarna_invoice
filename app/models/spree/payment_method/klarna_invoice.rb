# encoding: utf-8

class Spree::PaymentMethod::KlarnaInvoice < Spree::PaymentMethod
  preference :store_id,         :integer                    # 2029
  preference :store_secret,     :string                     # 3FPNSzybArL6vOg
  preference :mode,             :string,  default: :test    # live
  preference :invoice_fee,      :integer, default: 70
  preference :auto_activate,    :boolean, default: false
  preference :activate_in_days, :integer, default: 0
  preference :email_invoice,    :boolean, default: true
  preference :send_invoice,     :boolean, default: false
  preference :country_code,     :string,  default: 'SE'
  preference :currency_code,    :string,  default: 'SEK'
  preference :language_code,    :string,  default: 'SV'
  preference :logging,          :boolean, default: true
  preference :http_logging,     :boolean, default: false
  preference :timeout,          :integer, default: 10
  preference :pnr_formats,      :string,  default: 'YYMMDD-NNNN, YYMMDDNNNN'
  preference :pnr_min,          :integer, default: 8
  preference :pnr_max,          :integer, default: 10

  attr_accessible :store_id,
                  :store_secret,
                  :mode,
                  :invoice_fee,
                  :auto_activate,
                  :activate_in_days,
                  :email_invoice,
                  :send_invoice,
                  :country_code,
                  :language_code,
                  :logging,
                  :http_logging,
                  :timeout,
                  :preferred_store_id,
                  :preferred_store_secret,
                  :preferred_mode,
                  :preferred_invoice_fee,
                  :preferred_auto_activate,
                  :preferred_activate_in_days,
                  :preferred_email_invoice,
                  :preferred_send_invoice,
                  :preferred_country_code,
                  :preferred_language_code,
                  :preferred_logging,
                  :preferred_http_logging,
                  :preferred_timeout,
                  :preferred_currency_code,
                  :preferred_pnr_formats,
                  :preferred_pnr_min,
                  :preferred_pnr_max

  def source_required?
    true
  end

  def payment_source_class
    Spree::KlarnaPayment
  end

  def payment_profiles_supported?
    true
  end

  def purchase(money, payment_source, options = {})
    return payment_source.process!
  end

  # 11000,
  # #<Spree::KlarnaPayment:0x0000000a6bc6a0>,
  # {:email=>"spree@example.com", :customer=>"spree@example.com", :ip=>"127.0.0.1", :order_id=>"R435506100-9JANRGBN", :shipping=>#<BigDecimal:2fb9da0,'0.1E4',9(36)>, :tax=>0, :subtotal=>#<BigDecimal:2f438a8,'0.1E5',9(36)>, :discount=>0, :currency=>"USD", :billing_address=>{:name=>"Dmitry Vasilets", :address1=>"Kuglerstr 26", :address2=>"", :city=>"Berlin", :state=>"Berlin", :zip=>"10439", :country=>nil, :phone=>"+4917687624890"}, :shipping_address=>{:name=>"Dmitry Vasilets", :address1=>"Kuglerstr 26", :address2=>"", :city=>"Berlin", :state=>"Berlin", :zip=>"10439", :country=>nil, :phone=>"+4917687624890"}}
  def authorize(money, payment_source, options = {})
    purchase(money, payment_source, options)
  end
end

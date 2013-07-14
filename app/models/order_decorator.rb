# Encoding: utf-8
Spree::Order.class_eval do
  # FIXME looks like not required code
=begin
  def set_error(message)
    @@e_message = message
  end
=end

  def get_error
    Spree.t(:payment_processing_failed)
  end

  # true if to current order require add klarna invoice
  # FIXME require validate that order not support partitial payment
  def add_klarna?
    payment? &&
      adjustments.klarna_invoice_cost.count <= 0 &&
      payments.first.payment_method &&
      is_paymeth_klarna?
  end

  # tru if require remove klarna cost from current order
  def remove_klarna?
    payment? &&
      adjustments.klarna_invoice_cost.count > 0 &&
      payments.first.payment_method &&
      !is_paymeth_klarna?
  end

  # return true if current order use paymethod klarna
  def is_paymeth_klarna?
    klarna_name = 'Spree::PaymentMethod::KlarnaInvoice'
    payments.first.payment_method.class.name == klarna_name
  end

  # add to order adj with klarna fee
  def add_klarna_fee!
    if add_klarna?

      # FIXME require validation that order restrict partitial payments
      paymeth = payments.first.payment_method

      fee = paymeth.preferred(:invoice_fee)
      adj = adjustments.create(amount: fee,
                               source:  self,
                               label:      Spree.t(:invoice_fee))
      # FIXME define correct originator
      # paymenthod is not correct spree/core/app/models/spree/adjustment.rb
      # adj.originator = paymeth
      # adj.save!
      adj.lock!
      update!
    end
  end

  # delete from order all adj with klarna fee
  def remove_klarna_fee!
    if remove_klarna?
      adjustments.klarna_invoice_cost.destroy_all
      update!
    end
  end
end

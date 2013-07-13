Spree::Order.class_eval do
  def set_error(message)
    @@e_message = message
  end

  def get_error
    if @@e_message.blank?
      Spree.t(:payment_processing_failed)
    else
      @@e_message
    end
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
    payments.first.payment_method.class.name == 'Spree::PaymentMethod::KlarnaInvoice'
  end
end

# encoding: utf-8

Spree::BaseHelper.class_eval do
  def get_client_ip
    request.remote_ip
  end

  def validation_error_head
    "#{Spree.t(:pnr_validation_first)} "
  end

  def pnr_validation_error(min, max)
    mes = validation_error_head
    if min != max
      mes << validation_between(min, max)
    else
      mes << "#{Spree::PaymentMethod::KlarnaInvoice.first.preferred(:pnr_min)}"
    end
    mes << validation_error_tail
    return mes
  end

  def validation_between(min, max)
    mes = "#{Spree.t(:between)} "
    mes << "#{Spree::PaymentMethod::KlarnaInvoice.first.preferred(:pnr_min)} "
    mes << "#{Spree.t(:and)} "
    mes << "#{Spree::PaymentMethod::KlarnaInvoice.first.preferred(:pnr_max)} "
    return mes
  end

  def validation_error_tail
    result = "#{Spree.t(:chars)}. "
    result << Spree.t(:pnr_formats)
    result << ' '
    result << Spree::PaymentMethod::KlarnaInvoice.first.preferred(:pnr_formats)
    return result
  end
end

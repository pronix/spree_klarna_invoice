Spree::BaseHelper.class_eval do
  def get_client_ip
    request.remote_ip
  end

  def pnr_validation_error(min, max)
    if(min != max)
      "#{Spree.t(:pnr_validation_first)} #{Spree.t(:between)} #{Spree::PaymentMethod::KlarnaInvoice.first.preferred(:pnr_min)} #{Spree.t(:and)} #{Spree::PaymentMethod::KlarnaInvoice.first.preferred(:pnr_max)} #{Spree.t(:chars)}. #{Spree.t(:pnr_formats)} #{Spree::PaymentMethod::KlarnaInvoice.first.preferred(:pnr_formats)}"
    else
      "#{Spree.t(:pnr_validation_first)} #{Spree::PaymentMethod::KlarnaInvoice.first.preferred(:pnr_min)} #{Spree.t(:chars)}. #{Spree.t(:pnr_formats)} #{Spree::PaymentMethod::KlarnaInvoice.first.preferred(:pnr_formats)}"
    end
  end
end

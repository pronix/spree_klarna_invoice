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
end

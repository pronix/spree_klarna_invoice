# encoding: utf-8

Spree::CheckoutController.class_eval do
  before_filter :set_klarna_client_ip, only: [:update]

  # Updates the order and advances to the next state (when possible.)
  def update
    if @order.update_attributes(object_params)
      fire_event('spree.checkout.update')

      unless apply_coupon_code
        respond_with(@order) { |format| format.html { render :edit } }
        return
      end

      # Add Klarna invoice cost
      @order.add_klarna_fee!
      # Remove Klarna invoice cost
      @order.remove_klarna_fee!

      if @order.next
        # FIXME not working
        # state_callback(:after)
        # fix require recheck
        session[:order_id] = nil if @order.completed?
      else
        flash[:error] = @order.get_error # Changed by Noc
        respond_with(@order, location: checkout_state_path(@order.state))
        return
      end

      if @order.state == 'complete' || @order.completed?
        flash.notice = Spree.t(:order_processed_successfully)
        flash[:commerce_tracking] = 'nothing special'
        respond_with(@order, location: completion_route)
      else
        respond_with(@order, location: checkout_state_path(@order.state))
      end
    else
      respond_with(@order) { |format| format.html { render :edit } }
    end
  end

  def set_klarna_client_ip
    @client_ip = request.remote_ip # Set client ip
  end
end

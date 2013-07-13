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
      if @order.add_klarna?

        # FIXME require validation that order restrict partitial payments
        paymeth = @order.payments.first.payment_method

        fee = paymeth.preferred(:invoice_fee)
        adj = @order.adjustments.create(amount: fee,
                                  source:     @order,
                                  label:      Spree.t(:invoice_fee))
        # FIXME define correct originator
        # paymenthod is not correct spree/core/app/models/spree/adjustment.rb
        #adj.originator = paymeth
        #adj.save!
        adj.lock!
        @order.update!
      end

      # Remove Klarna invoice cost
      if @order.remove_klarna?
        @order.adjustments.klarna_invoice_cost.destroy_all
        @order.update!
      end

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

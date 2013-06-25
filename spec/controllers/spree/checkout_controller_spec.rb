require 'spec_helper'

describe Spree::CheckoutController do
  stub_authorization!

  before { controller.stub spree_current_user: create(:user) }

  context "controller instance" do
    it "use Spree::CheckoutController" do
      controller.should be_an_instance_of Spree::CheckoutController
    end
  end

  context "#update" do
    before do
    end

    specify do
    end
  end

  context "#set_klarna_client_ip" do
    before do
      ActionDispatch::Request.any_instance.stub(:remote_ip).and_return("192.168.0.1")
    end

    specify do
    end
  end
end

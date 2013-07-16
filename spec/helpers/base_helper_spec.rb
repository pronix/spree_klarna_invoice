# encoding: utf-8

require 'spec_helper'

describe Spree::BaseHelper do
  context "get_client_ip" do
    before do
      ActionDispatch::Request.any_instance.stub(:remote_ip).and_return("192.168.0.1")
    end

    specify do
      helper.get_client_ip.should == "192.168.0.1"
    end
  end

  # context "pnr_validation_error" do
  #   specify do
  #     helper.pnr_validation_error(1,2).should == ""
  #   end

  #   specify do
  #     helper.pnr_validation_error(2,2).should == ""
  #   end
  # end
end

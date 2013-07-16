# encoding: utf-8

require 'spec_helper'

describe Spree::KlarnaPayment do
  context "relation" do
    it { should have_many :payments }
  end

  context "validation" do
    it { should validate_presence_of :social_security_number }
    it { should validate_presence_of :firstname }
    it { should validate_presence_of :lastname }
  end

  context "mass assignent" do
    it { should allow_mass_assignment_of :firstname }
    it { should allow_mass_assignment_of :lastname }
    it { should allow_mass_assignment_of :social_security_number }
    it { should allow_mass_assignment_of :invoice_number }
    it { should allow_mass_assignment_of :client_ip }
  end

  context "actions" do
    specify do
      subject.actions.should be_a Array
      subject.actions.should == ["capture"]
    end
  end

  context "can_capture?" do
    specify do
    end
  end
end

require 'spec_helper'

describe Spree::KlarnaPayment do
  context "relation" do
    it { should have_many :payments, as: :source }
  end

  context "validation" do
    it { should validate_presence_of :social_security_number }
    it { should validate_presence_of :firstname }
    it { should validate_presence_of :lastname }
  end

  context "mass assignent" do
    it { should allow_mass_assignent_of :firstname }
    it { should allow_mass_assignent_of :lastname }
    it { should allow_mass_assignent_of :social_security_number }
    it { should allow_mass_assignent_of :invoice_number }
    it { should allow_mass_assignent_of :client_ip }
  end
end

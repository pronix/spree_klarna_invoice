require 'spec_helper'

describe Spree::Adjustment do
  context "mass assignent" do
    it { should allow_mass_assignment_of :source }
    it { should allow_mass_assignment_of :originator }
    it { should allow_mass_assignment_of :locked }
  end
end

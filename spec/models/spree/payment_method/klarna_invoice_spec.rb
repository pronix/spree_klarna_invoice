require 'spec_helper'

describe Spree::PaymentMethod::KlarnaInvoice do
  context "mass assignment" do
    %w(store_id
    store_secret
    mode
    invoice_fee
    auto_activate
    activate_in_days
    email_invoice
    send_invoice
    country_code
    language_code
    logging
    http_logging
    timeout
    preferred_store_id
    preferred_store_secret
    preferred_mode
    preferred_invoice_fee
    preferred_auto_activate
    preferred_activate_in_days
    preferred_email_invoice
    preferred_send_invoice
    preferred_country_code
    preferred_language_code
    preferred_logging
    preferred_http_logging
    preferred_timeout
    preferred_currency_code
    preferred_pnr_formats
    preferred_pnr_min
    preferred_pnr_max).each do |column|
      it { should allow_mass_assignment_of column.to_sym }
    end
  end

  context "source_required?" do
    specify do
      subject.source_required?.should be_true
    end
  end

  context "payment_source_class" do
    specify do
      subject.payment_source_class.should == Spree::KlarnaPayment
    end
  end

  context "payment_profiles_supported?" do
    specify do
      subject.payment_profiles_supported?.should be_true
    end
  end
end

require 'spec_helper'

describe Spree::PaymentMethod::KlarnaInvoice do
  context "mass assignent" do
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
      it { should allow_mass_assignent_of column.to_sym }
    end
  end

  context "method" do
    it "source_required?" do
      source_required?.should be_true
    end

    it "payment_source_class" do
      payment_source_class.should be_an_instance_of Spree::KlarnaPayment
    end

    it "payment_profiles_supported?" do
      payment_profiles_supported?.should be_true
    end
  end
end

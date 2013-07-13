FactoryGirl.define do
  factory :klarna_payment, class: Spree::KlarnaPayment do
    association(:source, factory: :payment)
    firstname { Faker::Name::first_name }
    lastname  { Faker::Name::last_name }
    social_security_number { (10000..20000).sample }
    invoice_number nil
    client_ip nil
  end

  factory :klarna_payment_method, class: Spree::PaymentMethod::KlarnaInvoice do
      name 'klarna'
      environment 'test'
      active true
  end
end

require 'spec_helper'

feature 'Buy' do
  background :each do
    # factories defined in spree/core/lib/spree/testing_support/factories
    # @calculator = create(:calculator)
    zone = create(:zone, name: 'CountryZone')


    @product = create(:base_product, name: 'product1')
    @country = create(:country,
                      iso_name: 'SWEDEN',
                      name: 'Sweden',
                      iso: 'SE',
                      iso3: 'SE',
                      numcode: 46 )
    @country.states_required = false
    @country.save!
    @state = @country.states.create(name: 'Stockholm')
    zone.members.create(zoneable: @country)

    FactoryGirl.create(:shipping_method).tap do |shipping_method|
      shipping_method.calculator.preferred_amount = 10
      shipping_method.calculator.save
      shipping_method.zones << zone
    end

    # defined in spec/factories/klarna_payment_factory
    @pay_method = create(:klarna_payment_method)
  end

  scenario 'visit root page' do
    name = @product.name
    visit '/'
    expect(page).to have_content(name)
    click_link name
    click_button 'add-to-cart-button'
    click_button 'checkout-link'
    fill_in 'order_email', with: 'test2@example.com'
    click_button 'Continue'

    # fill addresses
    # copy from spree/backend/spec/requests/admin/orders/order_details_spec.rb
    # may will in future require update
    check 'order_use_billing'
    fill_in 'order_bill_address_attributes_firstname', :with => 'Joe'
    fill_in 'order_bill_address_attributes_lastname', :with => 'User'
    fill_in 'order_bill_address_attributes_address1', :with => '7735 Old Georgetown Road'
    fill_in 'order_bill_address_attributes_address2', :with => 'Suite 510'
    fill_in 'order_bill_address_attributes_city', :with => 'Bethesda'
    fill_in 'order_bill_address_attributes_zipcode', :with => '20814'
    fill_in 'order_bill_address_attributes_phone', :with => '301-444-5002'
    within('fieldset#billing') do
      select @country.name , from: 'Country'
#      select @state.name, from: 'State'
    end

    click_button 'Save and Continue'

    # shipping
    save_and_open_page
    click_button 'Save and Continue'
    #save_and_open_page

    # payment page
    fill_in 'social_security_number', with: '410321-9202'
    click_button 'Save and Continue'

    # as result require receive invoice and check that invoice created in klarna
    save_and_open_page
  end
end

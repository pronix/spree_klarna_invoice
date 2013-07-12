require 'spec_helper'

feature 'Buy' do
  scenario 'visit root page' do
    visit '/'
    expect(page).to have_content('product1')
    select_product 'product1'
    order_product
    finish_order
  end
end

if Spree::PaymentMethod.table_exists? && klarna_invoice = Spree::PaymentMethod::KlarnaInvoice.first
  Deface::Override.new(virtual_path: 'spree/shared/_footer',
                       name:         'klarna_footer_logo',
                       insert_top:   '#footer-images .payments',
                       text:         "<%= image_tag 'https://cdn.klarna.com/public/images/#{klarna_invoice.preferred(:country_code).to_s}/badges/v1/invoice/#{klarna_invoice.preferred(:country_code).to_s}_invoice_badge_banner_blue.png?width=96&eid=#{klarna_invoice.preferred(:store_id).to_s}', id: 'klarna-image' if Spree::PaymentMethod::KlarnaInvoice.active? %>",
                       disabled:      false)
end

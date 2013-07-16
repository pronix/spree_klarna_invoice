# encoding: utf-8

Spree::Adjustment.class_eval do
  scope :klarna_invoice_cost, lambda { where('label LIKE ?', "#{Spree.t(:invoice_fee)}%") }
  attr_accessible :source, :originator, :locked
end

# frozen_string_literal: true

FactoryBot.define do
  factory :price_rule do
    contract { nil }
    product { nil }
    product_group { nil }
    price_group { nil }

    fixed_price { 1.5 }
    markup_percentage { 1.5 }
    discount_percentage { 1.5 }

    priority { 1 }
    active { true }
  end
end

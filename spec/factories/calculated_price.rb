# frozen_string_literal: true

FactoryBot.define do
  factory :calculated_price do
    contract { nil }
    offer { nil }
    price { 1.5 }
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :offer do
    product { nil }
    base_price { 1.5 }
    stock_quantity { 1 }
    delivery_time_days { 1 }
    bonus_points { 1 }
  end
end

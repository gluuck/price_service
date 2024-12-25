# frozen_string_literal: true

FactoryBot.define do
  factory :price_group do
    sequence(:name) { |n| "Price Group #{n}" }
  end
end

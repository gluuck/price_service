# frozen_string_literal: true

FactoryBot.define do
  factory :contract do
    customer { nil }
    number { 'MyString' }
    valid_from { '2023-01-30' }
    valid_until { '2023-01-30' }
    active { true }
  end
end

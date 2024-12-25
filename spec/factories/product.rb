# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    name { 'MyString' }
    sku { 'MyString' }
    brand { 'MyString' }
    description { 'MyText' }
    image_url { 'MyString' }
  end
end

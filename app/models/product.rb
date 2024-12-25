# frozen_string_literal: true

class Product < ApplicationRecord
  belongs_to :product_group, optional: true
  belongs_to :price_group, optional: true

  has_many :offers
  has_many :price_rules

  validates :name, presence: true
  validates :sku, presence: true, uniqueness: true

  after_commit :invalidate_cache

  private

  def invalidate_cache
    Contract.find_each do |contract|
      UpdatePricesCacheJob.perform_later(contract.id)
    end
  end
end

# frozen_string_literal: true

class ProductGroup < ApplicationRecord
  has_many :products
  has_many :price_rules

  validates :name, presence: true

  after_commit :invalidate_cache

  private

  def invalidate_cache
    Contract.find_each do |contract|
      UpdatePricesCacheJob.perform_later(contract.id)
    end
  end
end

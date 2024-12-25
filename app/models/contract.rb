# frozen_string_literal: true

class Contract < ApplicationRecord
  belongs_to :customer
  has_many :price_rules
  has_many :calculated_prices

  after_commit :invalidate_cache

  private

  def invalidate_cache
    UpdatePricesCacheJob.perform_later(id)
  end
end

# frozen_string_literal: true

class Offer < ApplicationRecord
  belongs_to :product
  has_many :calculated_prices

  validates :base_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :delivery_time_days, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :bonus_points, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  after_commit :invalidate_cache

  private

  def invalidate_cache
    Contract.find_each do |contract|
      UpdatePricesCacheJob.perform_later(contract.id)
    end
  end
end

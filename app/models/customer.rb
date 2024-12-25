# frozen_string_literal: true

class Customer < ApplicationRecord
  has_many :contracts
  has_many :calculated_prices, through: :contracts

  after_commit :invalidate_cache

  private

  def invalidate_cache
    contracts.find_each do |contract|
      UpdatePricesCacheJob.perform_later(contract.id)
    end
  end
end

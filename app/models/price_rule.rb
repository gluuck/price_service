# frozen_string_literal: true

class PriceRule < ApplicationRecord
  belongs_to :contract, optional: true
  belongs_to :product, optional: true
  belongs_to :product_group, optional: true
  belongs_to :price_group, optional: true

  validates :priority, presence: true
  validate :at_least_one_reference
  validate :price_modification_present

  after_commit :invalidate_cache

  scope :active, -> { where(active: true) }

  private

  def at_least_one_reference
    return if contract.present? || product.present? || product_group.present? || price_group.present?

    errors.add(:base, 'At least one reference (contract, product, product_group, or price_group) must be present')
  end

  def price_modification_present
    return if fixed_price.present? || markup_percentage.present? || discount_percentage.present?

    errors.add(:base, 'Either fixed_price, markup_percentage, or discount_percentage must be present')
  end

  def invalidate_cache
    if contract_id
      UpdatePricesCacheJob.perform_later(contract_id)
    else
      Contract.find_each do |contract|
        UpdatePricesCacheJob.perform_later(contract.id)
      end
    end
  end
end

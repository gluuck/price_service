# frozen_string_literal: true

class CalculatedPrice < ApplicationRecord
  belongs_to :contract
  belongs_to :offer

  validates :price, presence: true
  validates :calculated_at, presence: true
  validates :contract_id, uniqueness: { scope: :offer_id }
end

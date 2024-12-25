# frozen_string_literal: true

class UpdatePricesCacheJob < ApplicationJob
  queue_as :default

  def perform(contract_id, offer_ids = nil)
    contract = Contract.find(contract_id)
    calculator = PriceCalculatorService.new(contract)

    offers = if offer_ids
               Offer.where(id: offer_ids)
             else
               Offer.all
             end

    ActiveRecord::Base.transaction do
      offers.find_each do |offer|
        price = calculator.calculate_price(offer)
        CalculatedPrice.upsert(
          {
            contract_id: contract.id,
            offer_id: offer.id,
            price: price,
            calculated_at: Time.current
          },
          unique_by: %i[contract_id offer_id]
        )
      end
    end
  end
end

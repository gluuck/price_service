# frozen_string_literal: true
class PriceCalculatorService
  CACHE_LIFETIME = 1.hour

  def initialize(customer_contract)
    @customer_contract = customer_contract
  end

  def calculate_prices(offers)
    offers.map do |offer|
      get_price_with_cache(offer)
    end
  end

  def calculate_price(offer)
    product = offer.product
    base_price = offer.base_price

    Rails.cache.fetch(cache_key(offer), expires_in: CACHE_LIFETIME) do
      applicable_rules = find_applicable_rules(product)
      return base_price if applicable_rules.empty?

      rule = applicable_rules.first
      apply_rule(rule, base_price)
    end
  end

  private

  def get_price_with_cache(offer)
    cached_price = CalculatedPrice.find_by(
      contract: @customer_contract,
      offer: offer,
      calculated_at: (CACHE_LIFETIME.ago)..Time.current
    )

    if cached_price
      cached_price.price
    else
      price = calculate_price(offer)
      UpdatePricesCacheJob.perform_later(@customer_contract.id, [offer.id])
      price
    end
  end

  def find_applicable_rules(product)
    rules = []

    contract_rule = PriceRule.active
                             .where(contract_id: @customer_contract.id)
                             .first
    rules << contract_rule if contract_rule.present?

    product_group_rule = PriceRule.active
                                  .where(product_group_id: product.product_group_id)
                                  .first
    rules << product_group_rule if product_group_rule.present?

    price_group_rule = PriceRule.active
                                .where(price_group_id: product.price_group_id)
                                .first
    rules << price_group_rule if price_group_rule.present?

    product_rule = PriceRule.active
                            .where(product_id: product.id)
                            .first
    rules << product_rule if product_rule.present?

    rules
  end

  def apply_rule(rule, base_price)
    return rule.fixed_price if rule.fixed_price.present?

    if rule.markup_percentage.present?
      base_price * (1 + rule.markup_percentage / 100.0)
    elsif rule.discount_percentage.present?
      base_price * (1 - rule.discount_percentage / 100.0)
    else
      base_price
    end
  end

  def cache_key(offer)
    [
      'price_calculation',
      @customer_contract.id,
      offer.id,
      offer.updated_at.to_i,
      PriceRule.maximum(:updated_at).to_i
    ].join('/')
  end
end

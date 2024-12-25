# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PriceCalculatorService do
  let(:contract) { create(:contract) }
  let(:product_group) { create(:product_group) }
  let(:price_group) { create(:price_group) }
  let(:product) { create(:product, product_group: product_group, price_group: price_group) }
  let(:offer) { create(:offer, product: product, base_price: 100.0) }

  subject { described_class.new(contract) }

  describe '#calculate_prices' do
    context 'when no rules exist' do
      it 'returns base price' do
        expect(subject.calculate_prices([offer])).to eq([100.0])
      end
    end

    context 'with multiple rules' do
      let!(:contract_rule) { create(:price_rule, contract: contract, discount_percentage: 10) }
      let!(:product_group_rule) { create(:price_rule, product_group: product_group, markup_percentage: 20) }
      let!(:price_group_rule) { create(:price_rule, price_group: price_group, discount_percentage: 15) }
      let!(:product_rule) { create(:price_rule, product: product, fixed_price: 150.0) }

      it 'applies contract rule first' do
        expect(subject.calculate_prices([offer])).to eq([90.0]) # 100 - 10%
      end

      it 'applies product group rule if no contract rule exists' do
        contract_rule.destroy
        expect(subject.calculate_prices([offer])).to eq([120.0]) # 100 + 20%
      end

      it 'applies price group rule if no higher priority rules exist' do
        contract_rule.destroy
        product_group_rule.destroy
        expect(subject.calculate_prices([offer])).to eq([85.0]) # 100 - 15%
      end

      it 'applies product rule if no higher priority rules exist' do
        contract_rule.destroy
        product_group_rule.destroy
        price_group_rule.destroy
        expect(subject.calculate_prices([offer])).to eq([150.0]) # fixed price
      end
    end

    context 'with product rule types' do
      context 'with fixed price' do
        let!(:product_rule) { create(:price_rule, product: product, fixed_price: 150.0) }

        it 'applies fixed price' do
          expect(subject.calculate_prices([offer])).to eq([150.0])
        end
      end

      context 'with markup percentage' do
        let!(:product_rule) { create(:price_rule, product: product, markup_percentage: 20) }

        it 'applies markup to base price' do
          expect(subject.calculate_prices([offer])).to eq([120.0]) # 100 + 20%
        end
      end

      context 'with discount percentage' do
        let!(:product_rule) { create(:price_rule, product: product, discount_percentage: 30) }

        it 'applies discount to base price' do
          expect(subject.calculate_prices([offer])).to eq([70.0]) # 100 - 30%
        end
      end
    end

    context 'with caching' do
      let!(:contract_rule) { create(:price_rule, contract: contract, discount_percentage: 10) }

      it 'uses cache for subsequent calls' do
        expect(Rails.cache).to receive(:fetch).and_call_original
        first_result = subject.calculate_prices([offer])

        expect(Rails.cache).to receive(:fetch).and_return(90.0)
        second_result = subject.calculate_prices([offer])

        expect(first_result).to eq(second_result)
      end

      it 'invalidates cache when rule changes' do
        subject.calculate_prices([offer])
        contract_rule.update(discount_percentage: 20)

        expect(subject.calculate_prices([offer])).to eq([80.0]) # 100 - 20%
      end

      it 'creates calculated price record' do
        expect do
          subject.calculate_prices([offer])
        end.to change(CalculatedPrice, :count).by(1)

        calculated_price = CalculatedPrice.last
        expect(calculated_price.price).to eq(90.0)
        expect(calculated_price.contract).to eq(contract)
        expect(calculated_price.offer).to eq(offer)
      end
    end
  end
end

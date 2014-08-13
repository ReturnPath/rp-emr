require 'spec_helper'

describe RP::EMR::InstanceGroup do
  describe "#to_hash" do
    let(:group_args) { {} }

    let(:group) do
      RP::EMR::InstanceGroup.new(group_args) do |ig|
        ig.instance_role = 'instance_role'
        ig.instance_type = 'instance_type'
        ig.instance_count = 'instance_count'
      end
    end

    it "returns a hash" do
      expect(group.to_hash).to eq(
        :instance_role=>"instance_role",
        :instance_type=>"instance_type",
        :instance_count=>"instance_count",
      )
    end

    context "with name" do
      let(:group_args) { {name: 'name'} }

      it "sets name" do
        expect(group.to_hash[:name]).to eq('name')
      end
    end

    context "with market" do
      let(:group_args) { {market: 'market'} }

      it "sets name" do
        expect(group.to_hash[:market]).to eq('market')
      end
    end

    context "with bid_price" do
      let(:group_args) { {bid_price: 1.0} }

      it "sets market" do
        expect(group.to_hash[:market]).to eq('SPOT')
      end

      it "sets bid_price" do
        expect(group.to_hash[:bid_price]).to eq('1.0')
      end
    end
  end
end

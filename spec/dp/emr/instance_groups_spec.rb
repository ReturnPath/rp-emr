require 'spec_helper'

describe DP::EMR::InstanceGroups do
  describe "#to_a" do
    let(:group_args) { {} }

    let(:groups) do
      DP::EMR::InstanceGroups.new(group_args)
    end

    it "returns hash" do
      expect(groups.to_a).to eq([
        {
          :market=>"ON_DEMAND",
          :instance_role=>"MASTER",
          :instance_type=>"t1.micro",
          :instance_count=>1,
        },
        {
          :market=>"ON_DEMAND",
          :instance_role=>"CORE",
          :instance_type=>"t1.micro",
          :instance_count=>1,
        },
        {
          :market=>"ON_DEMAND",
          :instance_role=>"TASK",
          :instance_type=>"t1.micro",
          :instance_count=>1,
        },
      ])
    end

    context "with default_instance_type" do
      let(:group_args) { {default_instance_type: 'default_instance_type'} }

      it "sets instance type" do
        expect(groups.to_a.map { |h| h[:instance_type] }.uniq).to eq(['default_instance_type'])
      end
    end

    context "with instance_type" do
      let(:group_args) do
        {
          master_instance_type: 'master_instance_type',
          core_instance_type: 'core_instance_type',
          task_instance_type: 'task_instance_type',
        }
      end

      it "sets instance type" do
        expect(groups.to_a.map { |h| h[:instance_type] }).to eq([
          'master_instance_type',
          'core_instance_type',
          'task_instance_type',
        ])
      end
    end

    context "with instance_count" do
      let(:group_args) do
        {
          master_instance_count: 1,
          core_instance_count: 2,
          task_instance_count: 3,
        }
      end

      it "sets instance count" do
        expect(groups.to_a.map { |h| h[:instance_count] }).to eq([1, 2, 3])
      end
    end

    context "with bid_price" do
      let(:group_args) do
        {
          master_bid_price: 1,
          core_bid_price: 2,
          task_bid_price: 3,
        }
      end

      it "sets bid price" do
        expect(groups.to_a.map { |h| h[:bid_price] }).to eq(['1', '2', '3'])
      end

      it "sets market" do
        expect(groups.to_a.map { |h| h[:market] }.uniq).to eq(['SPOT'])
      end
    end

    context "with market" do
      let(:group_args) do
        {
          master_market: 'master_market',
          core_market: 'core_market',
          task_market: 'task_market',
        }
      end

      it "sets market" do
        expect(groups.to_a.map { |h| h[:market] }).to eq(['master_market', 'core_market', 'task_market'])
      end
    end
  end
end

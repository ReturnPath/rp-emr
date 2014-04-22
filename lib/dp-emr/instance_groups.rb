module DP
  module EMR
    class InstanceGroups
      extend Assembler

      assemble_from(
        default_instance_type: 't1.micro',

        master_instance_type: nil,
        master_instance_count: 1,
        master_market: 'ON_DEMAND',
        master_bid_price: nil,

        core_instance_type: nil,
        core_instance_count: 1,
        core_market: 'ON_DEMAND',
        core_bid_price: nil,

        task_instance_type: nil,
        task_instance_count: 1,
        task_market: 'ON_DEMAND',
        task_bid_price: nil,
      )

      def to_a
        [
          master_instance_group.to_hash, 
          core_instance_group.to_hash, 
          task_instance_group.to_hash,
        ].reject { |h| h[:instance_count] == 0 }
      end

      private

      def master_instance_group
        DP::EMR::InstanceGroup.new do |ig|
          ig.instance_role = 'MASTER'
          ig.instance_type = master_instance_type || default_instance_type
          ig.instance_count = master_instance_count
          ig.market = master_market
          ig.bid_price = master_bid_price
        end
      end

      def core_instance_group
        DP::EMR::InstanceGroup.new do |ig|
          ig.instance_role = 'CORE'
          ig.instance_type = core_instance_type || default_instance_type
          ig.instance_count = core_instance_count
          ig.market = core_market
          ig.bid_price = core_bid_price
        end
      end

      def task_instance_group
        DP::EMR::InstanceGroup.new do |ig|
          ig.instance_role = 'TASK'
          ig.instance_type = task_instance_type || default_instance_type
          ig.instance_count = task_instance_count
          ig.market = task_market
          ig.bid_price = task_bid_price
        end
      end
    end
  end
end

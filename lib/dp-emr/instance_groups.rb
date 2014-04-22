module DP
  module EMR
    class InstanceGroups
      extend Assembler

      assemble_from(
        default_instance_type: 't1.micro',

        master_instance_type: nil,
        master_instance_count: 1,
        master_bid_price: nil,

        core_instance_type: nil,
        core_instance_count: 1,
        core_bid_price: nil,

        task_instance_type: nil,
        task_instance_count: 1,
        task_bid_price: 2,
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
        EMR::InstanceGroup.new do |ig|
          ig.instance_role = 'MASTER'
          ig.instance_type = master_instance_type || default_instance_type
          ig.instance_count = master_instance_count
          if master_bid_price
            ig.market = 'SPOT'
            ig.bid_price = master_bid_price
          else
            ig.market = 'ON_DEMAND'
          end
        end
      end

      def core_instance_group
        EMR::InstanceGroup.new do |ig|
          ig.instance_role = 'CORE'
          ig.instance_type = core_instance_type || default_instance_type
          ig.instance_count = core_instance_count
          if core_bid_price
            ig.market = 'SPOT'
            ig.bid_price = core_bid_price
          else
            ig.market = 'ON_DEMAND'
          end
        end
      end

      def task_instance_group
        EMR::InstanceGroup.new do |ig|
          ig.instance_role = 'TASK'
          ig.instance_type = task_instance_type || default_instance_type
          ig.instance_count = task_instance_count
          if task_bid_price
            ig.market = 'SPOT'
            ig.bid_price = task_bid_price.to_s
          else
            ig.market = 'ON_DEMAND'
          end
        end
      end
    end
  end
end

module DP
  module EMR
    class InstanceGroup
      extend Assembler

      assemble_from(
        # Required params
        :instance_role,
        :instance_type,
        :instance_count,

        # Optional params
        name: nil,
        market: nil,
        bid_price: nil,
      )

      def to_hash
        {
          name: name,
          market: market,
          instance_role: instance_role,
          bid_price: bid_price.to_s,
          instance_type: instance_type,
          instance_count: instance_count,
        }.reject { |k,v| !v || (v.respond_to?(:empty?) && v.empty?) }
      end

      private

      def market
        bid_price ? 'SPOT' : @market
      end
    end
  end
end

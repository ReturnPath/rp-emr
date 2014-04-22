module DP
  module EMR
    # Bootstrap action wrapper
    #
    # @example
    #   def bootstrap_hadoop
    #     DP::EMR::BootstrapAction.new(
    #       name: 'Configure Hadoop',
    #       path: 's3://elasticmapreduce/bootstrap-actions/configure-hadoop',
    #       args: ['-c', 'fs.s3n.multipart.uploads.enabled=false']
    #     )
    #   end
    #
    #   def bootstrap_daemons
    #     DP::EMR::BootstrapAction.new(
    #       name: 'Configure Daemons',
    #       path: 's3://elasticmapreduce/bootstrap-actions/configure-daemons',
    #       args: ['--namenode-heap-size=15000'],
    #     )
    #   end
    #
    class BootstrapAction
      extend Assembler

      assemble_from :name, :path, args: []

      def to_hash
        {
          name: name,
          script_bootstrap_action: {
            path: path,
            args: args,
          },
        }
      end
    end
  end
end

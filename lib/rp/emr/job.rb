module RP
  module EMR
    class Job
      extend Assembler

      assemble_from(
        # Required params
        :instances,

        # Optional params
        steps: nil,
        log_uri: nil,
        additional_info: nil,
        release_label: nil,
        bootstrap_actions: nil,
        supported_products: nil,
        new_supported_products: nil,
        visible_to_all_users: true,
        job_flow_role: nil,
        service_role: nil,
        tags: nil,
      )

      def to_hash
        {
          instances: instances,
          log_uri: log_uri,
          additional_info: additional_info,
          steps: steps,
          bootstrap_actions: bootstrap_actions,
          supported_products: supported_products,
          new_supported_products: new_supported_products,
          visible_to_all_users: visible_to_all_users,
          job_flow_role: job_flow_role,
          service_role: service_role,
          tags: tags,
          release_label: release_label,
        }.reject { |k,v| !v || (v.respond_to?(:empty?) && v.empty?) }
      end
    end
  end
end

module DP
  module EMR
    class Instances
      extend Assembler

      assemble_from(
        # Optional params
        master_instance_type: nil,
        slave_instance_type: nil,
        instance_count: nil,
        instance_groups: nil,
        ec2_key_name: nil,
        placement: nil,
        keep_job_flow_alive_when_no_steps: nil,
        termination_protected: nil,
        hadoop_version: nil,
        ec2_subnet_id: nil,
      )

      def to_hash
        {
          master_instance_type: master_instance_type,
          slave_instance_type: slave_instance_type,
          instance_count: instance_count,
          instance_groups: instance_groups,
          ec2_key_name: ec2_key_name,
          placement: placement,
          keep_job_flow_alive_when_no_steps: keep_job_flow_alive_when_no_steps,
          termination_protected: termination_protected,
          hadoop_version: hadoop_version,
          ec2_subnet_id: ec2_subnet_id,
        }.reject { |k,v| !v || (v.respond_to?(:empty?) && v.empty?) }
      end
    end
  end
end

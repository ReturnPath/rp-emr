require_relative '../dp-emr'

module DP
  module EMR
    class CLI < Thor
      namespace :emr

      def self.cli_class_options(klass)
        klass.class_option :keep_alive, aliases: '-a', default: false, type: :boolean, desc: 'Set to true if you want the cluster to stay alive after completion/failure'
        klass.class_option :verbose, aliases: '-v', default: false, type: :boolean, desc: 'Print lots of stuff'
        klass.class_option :dry_run, default: false, type: :boolean, desc: "Don't actually talk to AWS"
      end
      cli_class_options(self)

      desc "create_job JOB_NAME", "Create an EMR job"
      def self.create_job_method_options(klass, defaults = {})
        klass.method_option(:ec2_key_name, 
          default: defaults[:ec2_key_name], 
          aliases: '-k', 
          banner: 'KEY_NAME', 
          desc: "An AWS keypair for the cluster.  Useful if you want to shell into the cluster",
        )
        klass.method_option(:default_instance_type,
          default: defaults[:default_instance_type],
          banner: 'INSTANCE_TYPE',
          desc: "The EC2 instance type to use for the cluster",
        )
        klass.method_option(:master_instance_type,
          default: defaults[:master_instance_type],
          banner: 'INSTANCE_TYPE',
          desc: "The EC2 instance type to use for the cluster master group",
        )
        klass.method_option(:master_instance_count,
          default: defaults[:master_instance_count],
          type: :numeric,
          banner: 'N',
          desc: "The number of task instances to create in the cluster master group",
        )
        klass.method_option(:core_instance_type,
          default: defaults[:core_instance_type],
          banner: 'INSTANCE_TYPE',
          desc: "The EC2 instance type to use for the cluster core group",
        )
        klass.method_option(:core_instance_count,
          default: defaults[:core_instance_count],
          type: :numeric,
          banner: 'N',
          desc: "The number of task instances to create in the cluster core group",
        )
        klass.method_option(:task_instance_type,
          default: defaults[:task_instance_type],
          banner: 'INSTANCE_TYPE',
          desc: "The EC2 instance type to use for the cluster task group",
        )
        klass.method_option(:task_instance_count,
          default: defaults[:task_instance_count],
          type: :numeric,
          banner: 'N',
          desc: "The number of task instances to create in the cluster task group",
        )
        klass.method_option(:task_bid_price,
          default: defaults[:task_bid_price],
          type: :numeric,
          banner: 'N.NN',
          desc: "If set, will use spot instances for task trackers with this bid price",
        )
      end
      create_job_method_options(self)
      def create_job(job_name, *)
        instances = DP::EMR::Instances.new do |i|
          i.hadoop_version = '2.2.0'
          i.ec2_key_name = options[:ec2_key_name] if options[:ec2_key_name]
          i.keep_job_flow_alive_when_no_steps = options[:keep_alive]

          i.instance_groups = DP::EMR::InstanceGroups.new do |ig|
            ig.default_instance_type = options[:default_instance_type] if options[:default_instance_type]

            ig.master_instance_type = options[:master_instance_type] if options[:master_instance_type]
            ig.master_instance_count = options[:master_instance_count] if options[:master_instance_count]

            ig.core_instance_type = options[:core_instance_type] if options[:core_instance_type]
            ig.core_instance_count = options[:core_instance_count] if options[:core_instance_count]

            ig.task_instance_type = options[:task_instance_type] if options[:task_instance_type]
            ig.task_instance_count = options[:task_instance_count] if options[:task_instance_count]
            ig.task_bid_price = options[:task_bid_price] if options[:task_bid_price]
          end.to_a
        end

        setup_debugging_step = DP::EMR::Step::SetupDebugging.new do |s|
          s.action_on_failure = 'CANCEL_AND_WAIT' if options[:keep_alive]
        end

        job = DP::EMR::Job.new do |job|
          job.log_uri = "s3://oib-mapreduce/logs/mosaic_analysis/#{job_name.underscore}"
          job.instances = instances.to_hash
          job.steps = [setup_debugging_step.to_hash]
        end

        if options[:dry_run]
          job_flow = OpenStruct.new(id: 'job_flow_id')
        else
          job_flow = AWS::EMR.new.job_flows.create(job_name, job.to_hash)
        end
        puts '-----------'
        puts "Created job flow #{job_flow.id} with #{args}, #{options}"
        pp job.to_hash if options[:verbose]

        return job_flow.id
      end

      desc "add_setup_pig_step JOB_ID", "Add a setup pig step to an existing job"
      def self.add_setup_pig_step_method_options(klass, defaults = {})
      end
      add_setup_pig_step_method_options(self)
      def add_setup_pig_step(job_id, *)
        job = AWS::EMR.new.job_flows[job_id]

        step = DP::EMR::Step::SetupPig.new do |s|
          s.action_on_failure = 'CANCEL_AND_WAIT' if options[:keep_alive]
        end

        job.add_steps([step.to_hash]) unless options[:dry_run]
        puts '-----------'
        puts "Added setup pig step to #{job.id} with #{args}, #{options}"
        pp step.to_hash if options[:verbose]
      end

      desc "add_rollup_step JOB_ID INPUT OUTPUT", "Add a S3DistCp rollup step to an existing job"
      def self.add_rollup_step_method_options(klass, defaults = {})
        klass.method_option(:rollup_input_pattern,
          default: defaults[:rollup_input_pattern],
          desc: 'Java-compatable regex to filter input',
        )
        klass.method_option(:rollup_group_by,
          default: defaults[:rollup_group_by],
          desc: 'Java-compatable regex with a single capture group',
        )
        klass.method_option(:rollup_target_size,
          default: defaults[:rollup_target_size],
          type: :numeric,
          desc: 'The target file size for rolled up files',
        )
      end
      add_rollup_step_method_options(self)
      def add_rollup_step(job_id, input, output, *)
        job = AWS::EMR.new.job_flows[job_id]
        
        step = DP::EMR::Step::S3DistCp.new(
          name: 'Rollup',
          src: input,
          dest: output,
        ) do |s|
          s.srcPattern = options[:rollup_input_pattern] if options[:rollup_input_pattern]
          s.groupBy = options[:rollup_group_by] if options[:rollup_group_by]
          s.targetSize = options[:rollup_target_size] if options[:rollup_target_size]
          s.action_on_failure = 'CANCEL_AND_WAIT' if options[:keep_alive]
        end

        job.add_steps([step.to_hash]) unless options[:dry_run]
        puts '-----------'
        puts "Added rollup step to #{job.id} with #{args}, #{options}"
        pp step.to_hash if options[:verbose]
      end

      desc "add_pig_script_step JOB_ID SCRIPT_PATH", "Add a Pig script step to an existing job"
      def self.add_pig_script_step_method_options(klass, defaults = {})
        klass.method_option(:pig_params,
          default: defaults[:pig_params] || {},
          aliases: '-p',
          type: :hash,
          banner: 'PARAM:VALUE',
          desc: 'Parameters to be passed to the pig script',
        )
      end
      add_pig_script_step_method_options(self)
      def add_pig_script_step(job_id, script_path, *)
        job = AWS::EMR.new.job_flows[job_id]
        
        step = DP::EMR::Step::Pig.new(
          name: 'Pig',
          script_path: script_path,
        ) do |s|
          s.pig_params = options[:pig_params] if options[:pig_params]
          s.action_on_failure = 'CANCEL_AND_WAIT' if options[:keep_alive]
          s.dry_run = options[:dry_run]
        end

        job.add_steps([step.to_hash]) unless options[:dry_run]
        puts '-----------'
        puts "Added pig script step to #{job.id} with #{args}, #{options}"
        pp step.to_hash if options[:verbose]
      end
    end
  end
end

DP::EMR::CLI.start if __FILE__ == $0

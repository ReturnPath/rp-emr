# Data Pipeline EMR Client

This is a Ruby library for creating & launching jobs on AWS's Elastic MapReduce
service. The library provides two basic tools: a set of classes to encapsulate
the data structures expected by the EMR client, and a set of Thor helpers to
simplify building job launchers.

## Client Wrapper

The AWS EMR client is very low level, and basically expects a hash of values.
dp-emr provides wrappers for the basic data types and some helpers for building
collections.  All objects are built using the
[assembler](https://github.com/benhamill/assembler) gem, so you can mix values
between method-call syntax and builder-block syntax.

The basic bits look like this:

```ruby
# Executes a script before the cluster starts processing steps
bootstrap_action = DP::EMR::BootstrapAction.new(name: 'action name') do |a|
  a.path = 's3://path_to_script_to_run'
  a.args = ['--option value', '--other-option value']
end

# Runs a hadoop jar.  This is the bare-bones version, you'll probably want to 
# use one of the classes in lib/dp/emr/step
step = DP::EMR::Step.new(name: 'step name') do |s|
  s.action_on_failure = 'CANCEL_AND_WAIT'
  s.hadoop_jar_step = {
    jar: 's3://path_to_jar',
    args: ['--option value', '--other-option value'],
  }
end

# Runs a pig script
pig_step = DP::EMR::Step::Pig.new(name: 'pig step') do |s|
  s.script_path = '/local/path/to/pig_script.pig'
  s.script_bucket = 'bucket_to_upload_script_to'
  s.args = ['--args_to_append_to_job']
  s.pig_params = {'PIG_PARAM' => 'value'}
  s.pig_version = '0.11.1.1'
  s.action_on_failure = 'CANCEL_AND_WAIT'
  s.dry_run = false
end

# There are also steps for setting up pig, setting up debugging, using S3DistCP, etc

# Creates an instance group.  As with DP::EMR::Step, you probably shouldn't be
# using this directly, just DP::EMR::InstanceGroups instead
instance_group = DP::EMR::InstanceGroup.new(name: 'custom instance group') do |ig|
  ig.instance_role = 'MASTER'
  ig.instance_type = 'c1.medium'
  ig.instance_count = 100
  ig.market = 'SPOT'
  ig.bid_price = 2.0
end

# Defines the different instances groups to be used.  All the options for 
# DP::EMR::InstanceGroup are supported, along with a defulat instance type
instance_groups = DP::EMR::InstanceGroups.new do |ig|
  ig.default_instance_type = 'c1.medium'

  ig.master_instance_type = 'c3.xlarge'

  ig.core_instance_count = 5

  ig.task_instance_count = 100
  ig.task_instance_market = 'SPOT'
  ig.task_bid_price = 2.0
end

# Top-level instance definition
instances = DP::EMR::Instances.new do |i|
  i.instance_groups = instance_groups
  i.ec2_key_name = 'my_key_name'
  i.hadoop_version = '2.0'
end

# Now we can construct the actual job
job = DP::EMR::Job.new do |j|
  j.instances = instances
  j.steps = [step, pig_step]
  j.ami_version = :latest
  j.bootstrap_actions = [bootstrap_action]
  j.visible_to_all_users = true
  j.job_flow_role = 'MyIAMRole'
  j.tags = ['analysis']
end

# Launch the job using the AWS API
AWS::EMR.new.job_flows.create('job_name', job.to_hash)
```


## Thor Helpers

The API wrapper is all fine and dandy, but it's still a pain to work with.  So
there's a set of Thor helpers to make building jobs easier - they define things
like defaults, option parsing, and other goodness.

The gem installs an script called `emr` which provides basic options if you want 
to build jobs interactively

```bash
bundle exec emr help
> Commands:
>   emr add_pig_script_step JOB_ID SCRIPT_PATH  # Add a Pig script step to an existing job
>   emr add_rollup_step JOB_ID INPUT OUTPUT     # Add a S3DistCp rollup step to an existing job
>   emr add_setup_pig_step JOB_ID               # Add a setup pig step to an existing job
>   emr create_job JOB_NAME                     # Create an EMR job
>   emr help [COMMAND]                          # Describe available commands or one specific command
> 
> Options:
>   -a, [--keep-alive], [--no-keep-alive]  # Set to true if you want the cluster to stay alive after completion/failure
>   -v, [--verbose], [--no-verbose]        # Print lots of stuff
>       [--dry-run], [--no-dry-run]        # Don't actually talk to AWS
```

While these can be useful, the real goal is to make it easy to roll your own
CLI using these as building blocks.  This is accomplished by providing class-level
helpers to import the options used for each step, allowing you to invoke them
as modular components.

For example:

```ruby
#!/usr/bin/env ruby

require 'dp/emr'
require 'thor'

class ExampleCLI < Thor
  # This brings all the class-level helpers in
  extend DP::EMR::CLI::TaskOptions

  # Creates shared options like --dry-run and --verbose
  cli_class_options

  # We're going to write a CLI for launching a pig script.  The first thing
  # we do is give it a name (this is standard Thor)
  desc "pig", "Test a pig script"

  # We'll need to launch a cluster to do our computation with.  This method adds
  # the options we'll use to create the cluster.  Values passed to the method are
  # used as the defaults
  create_job_method_options(
    default_instance_type: 'm1.large',
    core_instance_count: 2,
    task_instance_count: 6,
    job_flow_role: 'DataPipelineDefaultRole',
  )

  # Here we're importing the options used to control how Pig is setup
  add_setup_pig_step_method_options
    
  # And here were importing options used to create a Pig step generally
  add_pig_script_step_method_options(
    script_bucket: 'oib-mapreduce-rmichael',
  )

  # Let's define some options specific to the task we're trying to complete
  method_option :output, default: 'analysis/real_people'
  def pig
    script_path   = File.expand_path('../count_real.pig', __FILE__)
    input_path    = "s3://oib-mapreduce/input/insights/read_rate/2013-12-12"
    output_path   = "s3://oib-mapreduce-rmichael/#{options[:output]}/#{Date.today}"

    # These will be available in our Pig script as '$INPUT' and '$OUTPUT'
    pig_step_args = { pig_params: options[:pig_params].merge(
      'INPUT'   => input_path,
      'OUTPUT'  => output_path,
    )}

    # Now that we've constructed our options, we'll use the Thor task in lib/dp/emr/cli 
    # to create a job flow.  The task returns the job identifier, and we're passing
    # the options hash that Thor parsed for us (this is why we did all that setup
    # earlier)
    job_id = invoke 'emr:create_job', ['Real People Analysis'], options

    # The job has been created, so we'll add a step to setup pig
    invoke 'emr:add_setup_pig_step', [job_id], options

    # And finally we'll add our pig script.  Notice that we're merging the pig 
    # args into the options hash.  We could also have passed these options as CLI
    # options - this lets us to complicated stuff like date coersions in Ruby
    invoke 'emr:add_pig_script_step', [job_id, script_path], options.merge(pig_step_args)
  end
end

ExampleCLI.start
```

Now, we can get a nice help page describing all the options available to us

```bash
bundle exec ./example --help
> Commands:
>   example help [COMMAND]  # Describe available commands or one specific command
>   example pig             # Test a pig script
> 
> Options:
>   -a, [--keep-alive], [--no-keep-alive]  # Set to true if you want the cluster to stay alive after completion/failure
>   -v, [--verbose], [--no-verbose]        # Print lots of stuff
>       [--dry-run], [--no-dry-run]        # Don't actually talk to AWS

bundle exec ./example help pig
> Usage:
>   example pig
> 
> Options:
>   -k, [--ec2-key-name=KEY_NAME]                # An AWS keypair for the cluster.  Useful if you want to shell into the cluster
>       [--default-instance-type=INSTANCE_TYPE]  # The EC2 instance type to use for the cluster
>                                                # Default: m1.large
>       [--master-instance-type=INSTANCE_TYPE]   # The EC2 instance type to use for the cluster master group
>       [--master-instance-count=N]              # The number of task instances to create in the cluster master group
>       [--core-instance-type=INSTANCE_TYPE]     # The EC2 instance type to use for the cluster core group
>       [--core-instance-count=N]                # The number of task instances to create in the cluster core group
>                                                # Default: 2
>       [--task-instance-type=INSTANCE_TYPE]     # The EC2 instance type to use for the cluster task group
>       [--task-instance-count=N]                # The number of task instances to create in the cluster task group
>                                                # Default: 6
>       [--task-bid-price=N.NN]                  # If set, will use spot instances for task trackers with this bid price
>       [--job-flow-role=IAM_ROLE]               # IAM Role for the job flow
>                                                # Default: DataPipelineDefaultRole
>       [--script-bucket=BUCKET]                 # The S3 bucket to use for storing the Pig script
>                                                # Default: oib-mapreduce-rmichael
>   -p, [--pig-params=PARAM:VALUE]               # Parameters to be passed to the pig script
>       [--output=OUTPUT]
>                                                # Default: analysis/real_people
>   -a, [--keep-alive], [--no-keep-alive]        # Set to true if you want the cluster to stay alive after completion/failure
>   -v, [--verbose], [--no-verbose]              # Print lots of stuff
>       [--dry-run], [--no-dry-run]              # Don't actually talk to AWS

bundle exec ./example pig --ouput foo --dry-run
> -----------
> Created job flow job_flow_id with ["Real People Analysis"], {"keep_alive"=>false, "verbose"=>false, "dry_run"=>true, ...}
> -----------
> Added setup pig step to job_flow_id with ["job_flow_id"], {"keep_alive"=>false, "verbose"=>false, "dry_run"=>true, ...}
> -----------
> Added pig script step to job_flow_id with ["job_flow_id", "/Users/rmichael/work/emr-test/count_real.pig"], {"keep_alive"=>false, ...}
```

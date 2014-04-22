require 'assembler'

module DP
  module EMR
  end
end

require_relative 'dp-emr/instance_group'
require_relative 'dp-emr/instances'
require_relative 'dp-emr/step'
require_relative 'dp-emr/job'
require_relative 'dp-emr/instance_groups'
require_relative 'dp-emr/bootstrap_action'
require_relative 'dp-emr/step/pig'
require_relative 'dp-emr/step/s3_dist_cp'
require_relative 'dp-emr/step/setup_debugging'
require_relative 'dp-emr/step/setup_pig'

require 'active_support'
require 'active_support/core_ext/numeric'
require 'assembler'
require 'aws-sdk'
require 'ostruct'
require 'pp'
require 'thor'


module RP
  module EMR
  end
end

require_relative 'emr/cli'
require_relative 'emr/instance_group'
require_relative 'emr/instances'
require_relative 'emr/step'
require_relative 'emr/job'
require_relative 'emr/instance_groups'
require_relative 'emr/bootstrap_action'
require_relative 'emr/step/pig'
require_relative 'emr/step/s3_dist_cp'
require_relative 'emr/step/setup_debugging'
require_relative 'emr/step/setup_pig'

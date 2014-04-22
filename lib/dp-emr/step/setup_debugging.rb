module DP
  module EMR
    class Step
      class SetupDebugging
        extend Assembler

        assemble_from action_on_failure: nil

        def to_hash
          step.to_hash
        end

        private

        def step
          EMR::Step.new(
            name: "Setup Hadoop Debugging",
            action_on_failure: action_on_failure,
            hadoop_jar_step: {
              jar: 's3://us-east-1.elasticmapreduce/libs/script-runner/script-runner.jar',
              args: ['s3://us-east-1.elasticmapreduce/libs/state-pusher/0.1/fetch'],
            }
          )
        end
      end
    end
  end
end

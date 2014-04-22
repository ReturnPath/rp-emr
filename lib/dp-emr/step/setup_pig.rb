module DP
  module EMR
    class Step
      class SetupPig
        extend Assembler

        assemble_from(
          pig_version: '0.11.1.1',
          action_on_failure: nil,
        )

        def to_hash
          step.to_hash
        end

        private

        def step
          EMR::Step.new(
            name: "Setup Pig",
            action_on_failure: action_on_failure,
            hadoop_jar_step: {
              jar: 's3://us-east-1.elasticmapreduce/libs/script-runner/script-runner.jar',
              args: [
                's3://us-east-1.elasticmapreduce/libs/pig/pig-script',
                '--base-path',  's3://us-east-1.elasticmapreduce/libs/pig/',
                '--install-pig',
                '--pig-versions', pig_version,
              ]
            }
          )
        end
      end
    end
  end
end

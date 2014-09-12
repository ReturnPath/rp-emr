module RP
  module EMR
    class Step
      class SetupHive
        extend Assembler

        assemble_from(
          hive_version: 'latest',
          action_on_failure: nil,
        )

        def to_hash
          step.to_hash
        end

        private

        def step
          RP::EMR::Step.new(
            name: "Setup Hive",
            action_on_failure: action_on_failure,
            hadoop_jar_step: {
              jar: 's3://us-east-1.elasticmapreduce/libs/script-runner/script-runner.jar',
              args: [
                's3://us-east-1.elasticmapreduce/libs/hive/hive-script',
                '--base-path',  's3://us-east-1.elasticmapreduce/libs/hive/',
                '--install-hive',
                '--hive-versions', hive_version,
              ]
            }
          )
        end
      end
    end
  end
end

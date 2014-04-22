require 'digest/md5'

module DP
  module EMR
    class Step
      class Pig
        extend Assembler

        assemble_from(
          :name,
          :script_path,
          :script_bucket,
          args: [],
          pig_params: {},
          pig_version: '0.11.1.1',
          action_on_failure: nil,
          dry_run: false,
        )

        def to_hash
          @hash ||= begin
            upload_script! unless dry_run
            step.to_hash
          end
        end

        private

        def upload_script!
          # puts "Uploading to s3://#{script_bucket}/#{script_key}"
          s3.buckets[script_bucket].objects[script_key].write(script)
        end

        def script
          @script ||= File.open(script_path, 'r').read
        end

        def script_key
          @script_key ||= begin
            hash = Digest::MD5.hexdigest(script)
            "scripts/emr_gem/#{File.basename(script_path, '.pig')}_#{hash}.pig"
          end
        end

        def script_url
          "s3://#{script_bucket}/#{script_key}"
        end

        def step
          DP::EMR::Step.new(
            name: name,
            action_on_failure: action_on_failure,
            hadoop_jar_step: {
              jar: 's3://us-east-1.elasticmapreduce/libs/script-runner/script-runner.jar',
              args: hadoop_jar_base_args + args + formatted_params,
            }
          )
        end

        def hadoop_jar_base_args
          [
            's3://us-east-1.elasticmapreduce/libs/pig/pig-script',
            '--base-path', 's3://us-east-1.elasticmapreduce/libs/pig/',
            '--pig-versions', pig_version,
            '--run-pig-script',
          ]
        end

        def formatted_params
          [
            '--args',
            '-f', script_url,
          ] + pig_params.
            reject { |k, v| v.nil? }.
            flat_map { |k, v| ['-p', "#{k}=#{v}"] }
        end

        def s3
          AWS::S3.new
        end
      end
    end
  end
end

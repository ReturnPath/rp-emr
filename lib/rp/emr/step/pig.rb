require 'digest/md5'

module RP
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
          s3.bucket(script_bucket).object(script_key).put(body: script)
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
          RP::EMR::Step.new(
            name: name,
            action_on_failure: action_on_failure,
            hadoop_jar_step: {
              jar: 'command-runner.jar',
              args: hadoop_jar_base_args + args + formatted_params,
            }
          )
        end

        def hadoop_jar_base_args
          [
            'pig-script'
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
          Aws::S3::Resource.new
        end
      end
    end
  end
end

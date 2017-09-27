module RP
  module EMR
    class Step
      # Create a S3DistCp step
      # http://docs.aws.amazon.com/ElasticMapReduce/latest/DeveloperGuide/UsingEMR_s3distcp.html
      #
      # Handles annoying details like argument escaping
      #
      # Accepts all the input parameters listed in the documentation as of version 1.0.7.
      # 
      # @example
      #   step = S3DistCpStep.new do |s|
      #     s.src = 's3://bucket/input/prefix/'   # Note this is NOT Hadoop's glob syntax
      #     s.dest = 's3://bucket/output/path'
      #     s.srcPattern = 's3://bucket/input/prefix/[foo|bar].*\.eml'     # Input regex - see Java's regex docs
      #     s.groupBy = '.*([a-z0-9]{2}).tsv'     # Note that you need a capture group
      #     s.targetSize = 120.megabytes
      #     s.compression = 'snappy'
      #     s.deleteOnSuccess = true
      #   end
      #
      #   step.to_hash                            # => Ruby hash ready for use in :steps key of a job
      #
      class S3DistCp
        extend Assembler

        DEFAULT_S3_DISTCP_JAR = '/home/hadoop/lib/emr-s3distcp-1.0.jar'

        HASH_FIELDS = [
          :src,
          :dest,
          :groupBy,
          :targetSize,
          :outputCodec,
          :multipartUploadChunkSize,
          :startingIndex,
          :outputManifest,
          :previousManifest,
          :s3Endpoint,
          :srcPattern,
        ]

        BOOLEAN_FIELDS = [
          :s3ServerSideEncryption,
          :deleteOnSuccess,
          :disableMultipartUpload,
          :numberFiles,
          :copyFromManifest,
        ]

        assemble_from(name: 'S3DistCp',
                      action_on_failure: nil,
                      s3_distcp_jar: DEFAULT_S3_DISTCP_JAR)
        assemble_from(Hash[HASH_FIELDS.map { |f| [f, nil] }])
        assemble_from(Hash[BOOLEAN_FIELDS.map { |f| [f, false] }])

        def to_hash
          step.to_hash
        end

        private

        def step
          args = hash_field_args + boolean_fields_args
          if s3_distcp_jar == 'custom-runner.jar'
            args.unshift! "s3-dist-cp"
          end

          RP::EMR::Step.new(
            name: name,
            action_on_failure: action_on_failure,
            hadoop_jar_step: {
              jar: s3_distcp_jar,
              args: args,
            }
          )
        end

        def hash_field_args
          HASH_FIELDS.each do |f|
            raise ArgumentError, "I don't know how to handle whitespace" if send(f) =~ / /
          end

          HASH_FIELDS.
            map { |f| [f, send(f)] }.
            reject { |k, v| v.nil? }.
            flat_map { |k, v| ["--#{k}", v.to_s] }
        end

        def boolean_fields_args
          BOOLEAN_FIELDS.
            reject { |f| !send(f) }.
            map { |f| "--#{f}" }
        end
      end
    end
  end
end

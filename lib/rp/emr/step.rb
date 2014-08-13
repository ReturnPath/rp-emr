module RP
  module EMR
    class Step
      extend Assembler

      assemble_from(
        :name,
        action_on_failure: nil,
        hadoop_jar_step: nil,
      )

      def to_hash
        {
          name: name,
          action_on_failure: action_on_failure,
          hadoop_jar_step: hadoop_jar_step,
        }.reject { |k,v| !v || (v.respond_to?(:empty?) && v.empty?) }
      end
    end
  end
end

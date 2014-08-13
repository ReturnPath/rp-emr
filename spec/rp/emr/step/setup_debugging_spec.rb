require 'spec_helper'

describe RP::EMR::Step::SetupDebugging do
  describe "#to_hash" do
    let(:step_args) { {} }

    let(:step) do
      RP::EMR::Step::SetupDebugging.new(step_args)
    end

    it "returns hash" do
      expect(step.to_hash).to eq(
        :name=>"Setup Hadoop Debugging",
        :hadoop_jar_step=>{
          :jar=>"s3://us-east-1.elasticmapreduce/libs/script-runner/script-runner.jar", 
          :args=>["s3://us-east-1.elasticmapreduce/libs/state-pusher/0.1/fetch"]
        }
      )
    end

    context "with action_on_failure" do
      let(:step_args) { {action_on_failure: 'action_on_failure'} }

      it "sets the step action on failure" do
        expect(step.to_hash[:action_on_failure]).to eq('action_on_failure')
      end
    end
  end
end

require 'spec_helper'

describe RP::EMR::Step::SetupPig do
  describe "#to_hash" do
    let(:step_args) { {} }

    let(:step) do
      RP::EMR::Step::SetupPig.new(step_args)
    end

    it "returns hash" do
      expect(step.to_hash).to eq(
        :name=>"Setup Pig",
        :hadoop_jar_step=>{
          :jar=>"s3://us-east-1.elasticmapreduce/libs/script-runner/script-runner.jar", 
          :args=>[
            "s3://us-east-1.elasticmapreduce/libs/pig/pig-script", 
            "--base-path", "s3://us-east-1.elasticmapreduce/libs/pig/", 
            "--install-pig", 
            "--pig-versions", "0.11.1.1"
          ]
        }
      )
    end

    context "with pig_version" do
      let(:step_args) { {pig_version: 'pig_version'} }

      it "sets the pig version" do
        expect(step.to_hash[:hadoop_jar_step][:args]).to eq([
          "s3://us-east-1.elasticmapreduce/libs/pig/pig-script", 
          "--base-path", "s3://us-east-1.elasticmapreduce/libs/pig/", 
          "--install-pig", 
          "--pig-versions", "pig_version"
        ])
      end
    end

    context "with action_on_failure" do
      let(:step_args) { {action_on_failure: 'action_on_failure'} }

      it "sets the step action on failure" do
        expect(step.to_hash[:action_on_failure]).to eq('action_on_failure')
      end
    end
  end
end

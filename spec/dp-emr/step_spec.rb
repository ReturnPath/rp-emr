require 'spec_helper'

describe DP::EMR::Step do
  describe "#to_hash" do
    let(:step_args) { {} }

    let(:step) do
      DP::EMR::Step.new(step_args) do |s|
        s.name = 'name'
      end
    end

    it "returns a hash" do
      expect(step.to_hash).to eq(name: 'name')
    end

    context "with action_on_failure" do
      let(:step_args) { {action_on_failure: 'action_on_failure'} }

      it "sets action on failure" do
        expect(step.to_hash[:action_on_failure]).to eq('action_on_failure')
      end
    end

    context "with hadoop_jar_step" do
      let(:step_args) { {hadoop_jar_step: 'hadoop_jar_step'} }

      it "sets hadoop jar step" do
        expect(step.to_hash[:hadoop_jar_step]).to eq('hadoop_jar_step')
      end
    end
  end
end

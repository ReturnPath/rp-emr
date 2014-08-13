require 'spec_helper'

describe RP::EMR::Step::S3DistCp do
  describe "#to_hash" do
    let(:step_args) { {} }

    let(:step) do
      RP::EMR::Step::S3DistCp.new(step_args)
    end

    it "returns hash" do
      expect(step.to_hash).to eq(
        :name=>"S3DistCp",
        :hadoop_jar_step=>{
          :jar=>"/home/hadoop/lib/emr-s3distcp-1.0.jar",
          :args=>[]
        }
      )
    end

    context "with hash args" do
      let(:step_args) do
        {
          src: 'src',
          dest: 'dest',
          groupBy: '.*',
          outputCodec: nil,
        }
      end

      it "returns hash" do
        expect(step.to_hash[:hadoop_jar_step][:args]).to eq([
          '--src', 'src',
          '--dest', 'dest',
          '--groupBy', '.*',
        ])
      end
    end

    context "with numeric hash args" do
      let(:step_args) do
        {targetSize: 100}
      end

      it "converts to strings" do
        expect(step.to_hash[:hadoop_jar_step][:args]).to eq([
          '--targetSize', '100',
        ])
      end
    end

    context "with boolean args" do
      let(:step_args) do 
        {
          deleteOnSuccess: true,
          numberFiles: false,
        }
      end

      it "returns hash" do
        expect(step.to_hash[:hadoop_jar_step][:args]).to eq([
          '--deleteOnSuccess',
        ])
      end
    end

    context "with action_on_failure" do
      let(:step_args) { {action_on_failure: 'action_on_failure'} }

      it "sets the step action on failure" do
        expect(step.to_hash[:action_on_failure]).to eq('action_on_failure')
      end
    end

    context "with name" do
      let(:step_args) { {name: 'name'} }

      it "sets the step name" do
        expect(step.to_hash[:name]).to eq('name')
      end
    end
  end
end

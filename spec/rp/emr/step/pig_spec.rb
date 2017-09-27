require 'spec_helper'

describe RP::EMR::Step::Pig do
  describe "#to_hash" do
    let(:written) { [] }

    before(:each) do
      allow_any_instance_of(Aws::S3::Object).to receive(:put) do |data, args|
        written << args[:body]
      end
    end

    after(:each) do
      script.delete
    end

    let(:script_contents) { 'script_contents' }

    let(:script) do
      script = Tempfile.new('pig_step_test')
      script.write(script_contents)
      script.close
      script
    end

    let(:expected_script_path) do
      hash = Digest::MD5.hexdigest(script_contents)
      "scripts/emr_gem/#{File.basename(script.path, '.pig')}_#{hash}.pig"
    end

    let(:step_args) { {} }

    let(:step) do
      RP::EMR::Step::Pig.new(step_args) do |s|
        s.name = 'step_name'
        s.script_path = script.path
        s.script_bucket = 'script_bucket'
      end
    end

    it "writes script to expected path" do
      expect_any_instance_of(Aws::S3::Bucket).to receive(:object).with(expected_script_path).and_call_original

      step.to_hash
    end

    it "uploads pig script contents" do
      step.to_hash

      expect(written).to eq(['script_contents'])
    end

    it "returns hash" do
      expect(step.to_hash).to eq(
        :name=>"step_name", 
        :hadoop_jar_step=>{
          :jar=>"s3://us-east-1.elasticmapreduce/libs/script-runner/script-runner.jar",
          :args=>[
            "s3://us-east-1.elasticmapreduce/libs/pig/pig-script", 
            "--base-path", "s3://us-east-1.elasticmapreduce/libs/pig/", 
            "--pig-versions", "0.11.1.1", 
            "--run-pig-script", 
            "--args", 
            "-f", "s3://script_bucket/#{expected_script_path}",
          ]
        }
      )
    end

    context "with args" do
      let(:step_args) { {args: ['foo', 'bar']} }

      it "adds to the args array" do
        expect(step.to_hash[:hadoop_jar_step][:args]).to eq([
          "s3://us-east-1.elasticmapreduce/libs/pig/pig-script", 
          "--base-path", "s3://us-east-1.elasticmapreduce/libs/pig/", 
          "--pig-versions", "0.11.1.1", 
          "--run-pig-script", 
          "foo", "bar",
          "--args", 
          "-f", "s3://script_bucket/#{expected_script_path}",
        ])
      end
    end

    context "with pig_params" do
      let(:step_args) { {pig_params: {foo: 'bar'}} }

      it "adds to the args array" do
        expect(step.to_hash[:hadoop_jar_step][:args]).to eq([
          "s3://us-east-1.elasticmapreduce/libs/pig/pig-script", 
          "--base-path", "s3://us-east-1.elasticmapreduce/libs/pig/", 
          "--pig-versions", "0.11.1.1", 
          "--run-pig-script", 
          "--args", 
          "-f", "s3://script_bucket/#{expected_script_path}",
          "-p", "foo=bar",
        ])
      end
    end

    context "with pig_version" do
      let(:step_args) { {pig_version: 'pig_version'} }

      it "adds to the args array" do
        expect(step.to_hash[:hadoop_jar_step][:args]).to eq([
          "s3://us-east-1.elasticmapreduce/libs/pig/pig-script", 
          "--base-path", "s3://us-east-1.elasticmapreduce/libs/pig/", 
          "--pig-versions", "pig_version", 
          "--run-pig-script", 
          "--args", 
          "-f", "s3://script_bucket/#{expected_script_path}",
        ])
      end
    end

    context "with action_on_failure" do
      let(:step_args) { {action_on_failure: 'action_on_failure'} }

      it "sets the step action on failure" do
        expect(step.to_hash[:action_on_failure]).to eq('action_on_failure')
      end
    end

    context "with dry_run" do
      let(:step_args) { {dry_run: true} }

      it "doesn't upload pig script" do
        step.to_hash

        expect(written).to eq([])
      end
    end
  end
end

require 'spec_helper'

describe RP::EMR::Job do
  describe "#to_hash" do
    let(:instances_args) { {} }

    let(:instances) do
      RP::EMR::Instances.new(instances_args)
    end

    let(:job_args) { {} }

    let(:job) do
      RP::EMR::Job.new(job_args) do |j|
        j.instances = instances.to_hash
      end
    end

    it "returns a hash" do
      expect(job.to_hash).to eq(ami_version: 'latest', visible_to_all_users: true)
    end

    context "with stuff specified" do
      let(:job_args) { {ami_version: 'ami_version'} }

      it "adds stuff to hash" do
        expect(job.to_hash[:ami_version]).to eq('ami_version')
      end
    end
  end
end

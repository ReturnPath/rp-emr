require 'spec_helper'

describe RP::EMR::Instances do
  describe "#to_hash" do
    let(:instances_args) { {} }

    let(:instances) do
      RP::EMR::Instances.new(instances_args)
    end

    it "returns a hash" do
      expect(instances.to_hash).to eq({})
    end

    context "with stuff specified" do
      let(:instances_args) { {master_instance_type: 'master_instance_type'} }

      it "adds stuff to hash" do
        expect(instances.to_hash).to eq(master_instance_type: 'master_instance_type')
      end
    end
  end
end

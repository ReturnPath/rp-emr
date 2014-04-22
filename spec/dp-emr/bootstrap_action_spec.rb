require 'spec_helper'

describe DP::EMR::BootstrapAction do
  describe "#to_hash" do
    let(:action) do
      DP::EMR::BootstrapAction.new do |a|
        a.name = 'name'
        a.path = 'path'
        a.args = ['args']
      end
    end

    it "returns hash" do
      expect(action.to_hash).to eq(
        name: 'name',
        script_bootstrap_action: {
          path: 'path',
          args: ['args'],
        },
      )
    end
  end
end

require 'spec_helper'

describe SimpleUnits::Context do
  let(:api) { SimpleUnits::Context }
  describe "::define" do
    before(:each) do
      api.define_unit("meter") do |unit|
        unit.type = :length
      end
    end
    describe "::get_context" do
      it "should be able to fetch the context I just defined" do
        api.get_context("meter").should be_a api
        api.get_context("meter").name.should eq "meter"
        api.get_context("meter").type.should eq :length
      end
    end
  end
end
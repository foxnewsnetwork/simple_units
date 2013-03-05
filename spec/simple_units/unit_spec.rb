require 'spec_helper'

describe SimpleUnits::Unit do 
  let(:model) { SimpleUnits::Unit }
  let(:cc) { SimpleUnits::Context } 
  context "usage" do
    before :each do
      cc.define_unit("user") do |unit|
        unit.type = :people
      end
      cc.define_unit("faggots") do |unit|
        unit.type = :people
        unit.inspector = lambda { |value| "8==D #{value} G==8" }
      end
      cc.define_unit("baggage") do |unit|
        unit.type = :stuff
      end
    end 

    describe "::new" do
      let(:four) { model.new 4, "user" }
      let(:three) { model.new 3, "user" }
      let(:five) { model.new 5, "faggots" }
      let(:sixteen) { model.new 16, cc.get_context("baggage")}

      context "crap" do
        let(:crap) { model.new 33, RSpec }
        it "should throw an error that indictates you've passed crap to try to start a new unit" do
          expect { crap }.to raise_error(SimpleUnits::Unit::UnknownUnitError, "RSpec is a Module")
        end
      end
      it "should give me an unit of the correct number" do
        four.should be_a model
        four.value.should eq 4
        four.units.should eq "(user)"
        sixteen.should be_a model
        sixteen.value.should eq 16
        sixteen.units.should eq "(baggage)"
      end

      describe "#to_i" do
        it "should just give the absolute value of a current unit in integer form" do
          five.to_i.should eq 5
          three.to_i.should eq 3
          four.to_i.should eq 4
        end
      end

      describe "#to_f" do
        it "should give the absolute value as a float" do
          five.to_f.should eq 5.0
          three.to_f.should eq 3.0
          four.to_i.should eq 4.0
        end
      end

      describe "#inverse" do
        context "normal" do
          let(:one_fifth) { five.inverse }
          it "should properly invert a number" do
            one_fifth.to_f.should eq 0.2
          end
          it "should have the correct units" do
            one_fifth.units.to_s.should eq "(faggots^-1)"
          end
        end

        context "infinity" do
          let(:zero) { model.new 0, "faggots" }
          let(:infinity) { zero.inverse }
          it "should give me infinity" do
            infinity.value.should eq Float::INFINITY
          end
          it "should still be the correct units" do
            zero.units.to_s.should eq "(faggots)"
            infinity.units.to_s.should eq "(faggots^-1)"
          end
        end
      end

      describe "#/" do
        context "unitary" do
          let(:eleven) { model.new 11, "faggots" }
          let(:one) { eleven / eleven }
          let(:one2) { eleven * eleven.inverse }
          it "should support proper division" do
            one.value.should eq 1.0
          end

          it "should become a scalar at this point" do
            eleven.units.to_s.should eq "(faggots)"
            eleven.inverse.units.to_s.should eq "(faggots^-1)"
            one.units.to_s.should eq one2.units.to_s
            one.units.to_s.should eq ""
          end
        end
        
      end

      describe "#to_s" do
        specify { five.to_s.should eq "8==D 5 G==8" }
      end

      describe "#same_dimension?" do
        it "should be true when two units have the same context name" do
          four.same_dimension?(three).should be_true
          three.same_dimension?(four).should be_true
        end
      end
      describe "#+" do
        let(:seven) { four + three }
        it "should be able to add users together and give me the correct resulting number" do
          seven.should be_a model
          seven.value.should eq 7
          seven.units.should eq "(user)"
        end
      end
      describe "#-" do
        let(:one) { four - three }

        it "should subtract an user from others" do
          one.should be_a model
          one.value.should eq 1
          one.units.should eq "(user)"
        end
      end
      describe "#*" do

        context "dimensional" do
          let(:twelve) { four * three }
          it "should produce a squared user when two users are multiplied" do
            twelve.should be_a model
            twelve.value.should eq 12
            twelve.units.should eq "(user^2)"
          end

          describe "#+" do
            it "should throw an error when you attempt to add together things of differing units" do
              expect { twelve + four }.to throw_symbol :CannotConvertDimension
            end
          end
        end

        context "scalar" do
          let(:sixty_six) { three * 22 }
          it "should still have the same model with the same units, but be scaled up 22 times" do
            sixty_six.should be_a model
            sixty_six.value.should eq 66
            sixty_six.units.should eq three.units
          end 
        end

        context "nonsensical" do
          let(:crap) { three * RSpec }

          it "should throw an error since it doesn't make sense to multiple numbers with units to random objects" do
            expect { crap }.to raise_error( SimpleUnits::Unit::MismatchError, "RSpec is a Module" )
          end
        end
      end
      describe "#to_str" do
        it "should stringify simply and predicably" do
          four.to_str.should eq four.to_s
          four.to_str.should eq "4 (user)"
        end
      end
    end
  end
end
require 'spec_helper'

describe SimpleUnits::Composite do
  let(:api) { SimpleUnits::Composite }
  let(:cc) { SimpleUnits::Context }
  before :each do
    cc.define_unit("dog") { |unit| unit.type = :animal }
    cc.define_unit("cat") { |unit| unit.type = :animal }
    cc.define_unit("user") { |unit| unit.type = :person }
  end
  describe "::new" do
    let(:composite) { api.new }
    let(:dog) { cc.get_context "dog" }
    let(:cat) { cc.get_context "cat" }
    let(:user) { cc.get_context "user" }

    specify { composite.should be_a api }

    describe "#==" do
      let(:pet_owner) { api.new }
      let(:faggot) { api.new }
      before :each do
        pet_owner.append_numerators! dog
        pet_owner.append_denominators! user
        faggot.append_numerators! dog, cat, user, dog, cat
        faggot.append_denominators! dog, cat, cat, user, user
      end

      it "should be equal since we simplify the units" do
        pet_owner.should == faggot
      end

      it "should not equal to things with differing units" do
        pet_owner.append_numerators! user
        pet_owner.should_not == faggot
      end
    end

    describe "#*" do
      let(:dog_per_user) { api.new }
      let(:cat_per_user) { api.new }
      let(:dog_cat_per_user_squared) { dog_per_user * cat_per_user }
      before :each do
        dog_per_user.append_numerators! dog
        dog_per_user.append_denominators! user
        cat_per_user.append_numerators! cat
        cat_per_user.append_denominators! user
      end

      context "reductions" do
        describe "#inverse" do
          let(:user_per_dog) { dog_per_user.inverse }
          let(:user_per_cat) { cat_per_user.inverse }
          it "should properly give me the units for user per dog" do
            user_per_dog.to_s.should eq "(dog^-1)(user)"
            dog_per_user.to_s.should eq "(dog)(user^-1)"
            user_per_cat.to_s.should eq "(cat^-1)(user)"
            cat_per_user.to_s.should eq "(cat)(user^-1)"
          end

          describe "#*" do
            let(:scalar) { dog_per_user * user_per_dog }
            it "should reduce down to a scalar if something is hit with its inverse" do
              scalar.numerators.should eq({})
              scalar.denominators.should eq({})
              scalar.to_s.should eq ""
            end
          end
        end
      end

      describe "#numerators" do
        before :each do
          @expected = {
            "dog" => { :order => 1, :context => dog },
            "cat" => { :order => 1, :context => cat }
          }
        end

        it "should match the numerator list" do
          dog_cat_per_user_squared.numerators.should eq @expected
        end
      end

      describe "#denominators" do
        before :each do
          @expected = {
            "user" => { :order => -2, :context => user }
          }
        end

        it "should match the numerator list" do
          dog_cat_per_user_squared.denominators.should eq @expected
        end
      end

      describe "#to_str" do
        before(:each) { @expected = "(cat)(dog)(user^-2)" }

        specify { dog_cat_per_user_squared.to_str.should eq @expected }
      end
    end

    describe "#append_numerators" do
      before :each do
        composite.append_numerators! dog, cat, user
      end

      describe "#numerators" do
        before :each do
          @expected = {
            "dog" => {:order => 1, :context => dog} ,
            "cat" => {:order => 1, :context => cat} ,
            "user" => {:order => 1, :context => user} 
          }
        end

        it "should spit out all the numerators involved in building my composite" do
          composite.numerators.count.should eq @expected.count
          composite.numerators.should eq @expected
        end
      end

      describe "#denominators" do
        specify { composite.denominators.should be_empty }
      end

      describe "#to_str" do
        before :each do
          @expected = "(cat)(dog)(user)"
        end

        it "should be an alias to to_s" do
          composite.to_str.should eq composite.to_s
        end

        it "should give me the expected string result" do
          composite.to_str.should eq @expected
        end
      end

      describe "#append_denominators" do
        before :each do
          composite.append_denominators! dog, dog, dog
        end

        describe "#numerators" do
          before :each do
            @expected = {
              "cat" => {:order => 1, :context => cat} ,
              "user" => {:order => 1, :context => user}    
            }
          end

          it "should spit out only the numerators as in things with order > 0" do
            composite.numerators.should eq @expected
          end
        end

        describe "#denominators" do
          before :each do
            @expected = {
              "dog" => { :order => -2, :context => dog }
            }
          end
          it "should have the denominators as per expectation" do
            composite.denominators.should eq @expected
          end
        end

        describe "#to_str" do
          before :each do
            @expected = "(cat)(dog^-2)(user)"
          end
          it "should give me the expected stringified version as well as match its alias" do
            composite.to_s.should eq @expected
            composite.to_str.should eq composite.to_s
          end
        end
      end
    end
  end

end
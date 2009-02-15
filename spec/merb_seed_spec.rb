require File.join( File.dirname(__FILE__), "spec_helper")

describe "merb_seed" do
  
  describe "datamapper support" do  
    before(:each) do
      load File.join( File.dirname(__FILE__), "fixtures", "dm_models.rb")
    end

    it "should create a model if one doesn't exist" do
      User.seed(:id) do |s|
        s.id = 1
        s.login = "bob"
        s.first_name = "Bob"
        s.last_name = "Bobson"
        s.title = "Peon"
      end

      bob = User.get(1)
      bob.first_name.should == "Bob"
      bob.last_name.should == "Bobson"
    end

    it "should be able to handle multiple constraints" do
      User.seed(:title, :login) do |s|
        s.login = "bob"
        s.title = "Peon"
        s.first_name = "Bob"
      end

      User.count.should == 1

      User.seed(:title, :login) do |s|
        s.login = "frank"
        s.title = "Peon"
        s.first_name = "Frank"
      end

      User.count.should == 2

      User.first(:first_name => "Bob").first_name.should == "Bob"
      User.seed(:title, :login) do |s|
        s.login = "bob"
        s.title = "Peon"
        s.first_name = "Steve"
      end
      User.first(:first_name => "Steve").first_name.should == "Steve"
    end

    it "should be able to create models from an array of seed attributes" do
      User.seed_many(:title, :login, [
        {:login => "bob", :title => "Peon", :first_name => "Steve"},
        {:login => "frank", :title => "Peasant", :first_name => "Francis"},
        {:login => "harry", :title => "Noble", :first_name => "Harry"}
      ])

      User.first(:login => "bob").first_name.should == "Steve"
      User.first(:login => "frank").first_name.should == "Francis"
      User.first(:login => "harry").first_name.should == "Harry"
    end

  end
end
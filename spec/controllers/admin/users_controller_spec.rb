require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

describe Admin::UsersController do
  
  # check authorization
  describe "it should require an admin to access these actions" do
    it_should_require_admin_for_action :index, :show, :new, :update, :create, :edit, :destroy 
  end
  
  describe "it should allow admin to access all actions" do
    it_should_allow_admin_for_action :index, :show, :new, :update, :create, :edit, :destroy
  end
  
  describe "it should allow non admin to edit & update their record only" do
    it_should_allow_non_admin_for_action :edit, :params => "1"
    it_should_allow_non_admin_for_action :update, :params => "1"
    it_should_allow_non_admin_for_action :show, :params => "1"   
  end
  
  #for actions
  let(:current_user) { logged_in(:role? => true) }
  let(:user) { mock_model("User").as_null_object }
  
  before(:each) do
    cas_faker(current_user.username)
  end
  
  describe "GET index" do
    def do_get     
      get :index
    end
           
    context "when the user is an admin they can view user records" do
      let(:users) { [mock_model("User", :username => "foo", :role => "admin"),
                    mock_model("User", :username => "bar", :role => "editor")] } 
      
      before(:each) do
        User.stub(:all).and_return(users)
      end

      it "should receive find all" do   
        User.should_receive(:all).and_return(users)
        do_get
      end
    
      it "should assign the found users" do
        do_get
        assigns(:users).should eq(users)
      end
    
      it "should render index template" do
        do_get
        response.should render_template("admin/users/index")
      end  
    end   
  end
  
  describe "GET show" do
    let(:params) {{ :id => "1" }}
    def do_get
      get :show, :id => "1"
    end
    
    before(:each) do
      User.stub(:find).and_return(user)
    end
    
    it "should should receive find" do
      User.should_receive(:find).with(params[:id]).and_return(user)
      do_get
    end
    
    it "should assign @user for the view" do
      do_get
      assigns(:user).should eq(user)
    end
    
    it "should render the EDIT template" do
      do_get
      response.should render_template("admin/users/edit")
    end
  end
  
  describe "GET new" do    
    
    before(:each) do 
      user.as_new_record
      User.stub(:new).and_return(user)   
    end
    
    def do_get     
      get :new
    end  
    
    it "should receive new the new and return a new user" do   
      User.should_receive(:new).and_return(user)
      do_get
    end
  
    it "should assign the found user" do
      do_get
      assigns(:user).should eq(user)
    end
  
    it "should render new template" do
      do_get
      response.should render_template("admin/users/new")
    end
  end     
  
  
  describe "POST create" do 
    let(:params) {{ "user" => { "username" => "foobar", "email" => "foobar@example.com", "role" => "admin" }}}
    
    before(:each) do 
      user.as_new_record      
      User.stub(:new).and_return(user)
    end  
    
    def do_post       
      post :create, params
    end  
              
    it "should create a new user" do
      User.should_receive(:new).with(params["user"]).and_return(user) 
      do_post                                                               
      assigns(:user).should eq(user) 
    end  
    
    context "when it save the new user successfully" do
      before(:each) do
        user.stub(:save).and_return(true)
      end         
      
      it "should should create a flash notice" do 
        do_post
        flash[:notice].should == "Successfully created user account for #{user.username}"
      end 
      
      it "should redirect to the admin users path" do
        do_post
        response.should redirect_to(admin_users_path)
      end
    end
    
    context "when the save fails" do                    
      it "should redirect to new template" do 
        user.stub(:save).and_return(false)            
        do_post
        response.should render_template("admin/users/new")
      end
    end 
  end 
  
  describe "GET edit" do 

    def do_get    
      get :edit, { :id => user.to_param }
    end     
          
    context "when the user is an admin they can edit user records" do
      before do                                    
        logged_in(:role? => true)
        User.stub(:find).and_return(user)     
      end             
    
      it "should receive find all" do   
        User.should_receive(:find).and_return(user)
        do_get
      end
    
      it "should assign the found users" do
        do_get
        assigns(:user).should eq(user)
      end
    
      it "should render index template" do
        do_get
        response.should render_template("admin/users/edit")
      end  
    end 
  end

  describe "PUT update" do    
    let(:params) {{ "id" => user.to_param, "user" => { "username" => "baz", "email" => "baz@example.com", "role" => "editor" }}}    
    before(:each) do   
      controller.stub(:admin?).and_return(true) 
      User.stub(:find).and_return(user)
    end  
    
    def do_put 
      put :update, params
    end

    it "should find the record to update" do
      User.should_receive(:find).with(params["id"]).and_return(user)
      do_put
    end 
    
    it "should assign @user for the view" do  
      do_put
      assigns(:user).should eq(user)
    end
    
    it "should update the user record" do
      user.should_receive(:update_attributes).with(params["user"]).and_return(true)
      do_put
    end 
      
    it "should set a flash[:notice] message" do
      do_put
      flash[:notice].should == "Successfully updated user account for #{user.username}"
    end         
    
    it "should redirect to INDEX" do
      do_put
      response.should redirect_to(admin_users_path)
    end                                                                       
  
    context "when update_attributes fails" do
      it "should render the edit template" do
        user.stub(:update_attributes).and_return(false)
        do_put  
        response.should render_template("admin/users/edit")
      end
    end
    
    context "if user is not an admin delete role param" do
      it "should not change the user role to admin" do
        controller.stub(:admin?).and_return(false)  
        params["user"].delete("role")
        user.should_receive(:update_attributes).with(params["user"]).and_return(true)
        do_put
      end
      
      it "should render the template for the users account" do
        controller.stub(:admin?).and_return(false)
        do_put
        response.should render_template("admin/users/edit")
      end
    end 
  end
  
  describe "DELETE destroy" do
    
    def do_destroy  
      delete :destroy, :id => "1"
    end
    
    before(:each) do
      User.stub(:find).and_return(user)
    end
    
    it "should receive the find method and return the user to destroy" do
      User.should_receive(:find).with("1").and_return(user)
      do_destroy
    end 
    
    it "should assign the user for the view" do
      do_destroy
      assigns(:user).should eq(user)
    end    
    
    it "should destroy the user account" do
      user.should_receive(:destroy).and_return(true)
      do_destroy 
    end
    
    it "should set a flash message" do
      do_destroy
      flash[:notice].should == "Successfully deleted user account for #{user.username}"
    end
    
    it "should redirect to admin_users index action" do
      do_destroy
      response.should redirect_to(admin_users_path) 
    end
  end
end
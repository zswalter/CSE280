class UsersController < ApplicationController

  def index
    @users = User.paginate(:page => params[:page])
    @count = 1

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  def show
    @user = current_user
  end

  def edit
    if current_user
      @user = current_user
    else
      @user = User.find(params[:id])
    end
    @edituser = true
  end

  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end
  
  def create
     @user = User.new(params[:user])
        if @user.save_without_session_maintenance # prevents automatically logging user in after registration
          flash[:notice] = "Account registered!"
          redirect_to root_path
        else
          render :action => :new
        end
  end


  def update
    
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to root_path
    else
      render :action => :edit
    end
    
  end



  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
end

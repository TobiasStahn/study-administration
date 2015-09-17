class UsersController < ApplicationController
  
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  helper_method :sort_column, :sort_direction

  # GET /users
  # GET /users.json
  def index
    @users = User.search(params[:search]).order(sort_column + " " + sort_direction).paginate(:per_page => 10, :page => params[:page])
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params.except(:profiles))
    respond_to do |format|
      if @user.save

        # Send email to user
        UserMailer.welcome_email(@user).deliver_now
        @user.profile = Profile.create(user_params[:profiles])

        login(user_params[:email], user_params[:password], false)

        format.html { redirect_to @user.profile}
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    authorize! :update, @user
    
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'Benutzer wurde erfolgreich editiert.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'Benutzer wurde erfolgreich gelöscht.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:email, :crypted_password, :password, :password_confirmation, :role, :course_id, profiles: [:name, :family_name])
    end

    def sort_column
      User.column_names.include?(params[:sort]) ? params[:sort] : "email"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end

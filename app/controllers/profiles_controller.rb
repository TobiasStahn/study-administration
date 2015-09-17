class ProfilesController < ApplicationController 
   
  load_and_authorize_resource

  before_action :set_profile, only: [:show, :edit, :update, :destroy]

  # GET /profiles
  # GET /profiles.json
  def index
    @profiles = Profile.all
  end

  # GET /profiles/1
  # GET /profiles/1.json
  def show
    @users = current_user
    @profile = @users.profile
  end

  # GET /profiles/new
  def new
    @profile = Profile.new
  end

  # POST /profiles
  # POST /profiles.json
  def create
    @profile = Profile.new(profile_params)

    respond_to do |format|
      if @profile.save
        format.html { redirect_to @profile, notice: 'Profil wurde erfolgreich erstellt.' }
        format.json { render :show, status: :created, location: @profile }
      else
        format.html { render :new }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /profiles/1
  # PATCH/PUT /profiles/1.json
  def update
    if profile_params[:user_attributes][:password] == profile_params[:user_attributes][:password_confirmation] || profile_params[:user_attributes][:password] == nil
      @profile.user = User.update(@profile.user.id, profile_params[:user_attributes]) # updates the user by updating the given params
      if !current_user.nil?
        if current_user.role == "admin" || current_user.id == @profile.user.id 
          valid = true
          unless params[:event].nil?
            params[:event][:event_ids].each do |i|
              unless i.blank? or i.nil?
                if params[('semester' + i.to_s).to_sym].nil?
                  valid = false
                end
              end
            end
            # Passed events are delivered in the join table events_users, while the profil is updated.
            params[:event][:event_ids].each do |i| 
              unless i.blank? or i.nil?
                event = Event.find(i)
                if valid
                  if !event.users.find_by(id: current_user.id)
                    event.users << current_user 
                    cu = event.events_users.find_by(user_id: current_user.id)
                    cu.semester = params[('semester' + i.to_s).to_sym]
                    cu.save!
                  else 
                    event.users.delete(current_user.id)
                    event.users << current_user 
                    cu = event.events_users.find_by(user_id: current_user.id)
                    cu.semester = params[('semester' + i.to_s).to_sym]
                    cu.save!
                  end  
                else 
                  redirect_to :back, alert: "Zu jeder bestandenen Veranstaltung muss das Semester angegeben werden!" and return
                end
              end
            end
          end
          if @profile.update(profile_params.except(:user_attributes).except(:event))
            redirect_to "/profiles/#{@profile.id}", notice: "Profil erfolgreich bearbeitet!" and return
          else
            redirect_to '/profiles/#{@profile.id}/edit', alert: "Fehler. Bitte nochmal versuchen." and return
          end
        else
          redirect_to :back, alert: "Keine Rechte." and return
        end
      else 
        redirect_to :back, alert: "Nicht eingeloggt." and return
      end
    else
      redirect_to :back, alert: "Passwörter stimmen nicht überein." and return
    end
  end
      
  # DELETE /profiles/1
  # DELETE /profiles/1.json
  def destroy
    @profile.destroy
    respond_to do |format|
      format.html { redirect_to profiles_url, notice: 'Profil wurde erfolgreich gelöscht.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_profile
      @profile = Profile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def profile_params
      params.require(:profile).permit(:family_name, :name, :birth_date, :bio, :user_id, user_attributes: [:role, :course_id, :id, :password, :password_confirmation, :crypted_password])
    end
end

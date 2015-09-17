class EventsController < ApplicationController
  


  before_action :set_event, only: [:show, :edit, :update, :destroy]

  helper_method :sort_column, :sort_direction

  # GET /events
  # GET /events.json
  def index
    authorize! :index, @events
    if !current_user || current_user.role == 'admin'
      @events = Event.all
    else
      @events = Event.all.where("id IN (SELECT events.id FROM events, blocks_events, blocks, blocks_courses WHERE
                                events.id = blocks_events.event_id AND blocks_events.block_id = blocks.id AND
                                blocks.id = blocks_courses.block_id AND blocks_courses.course_id = " + current_user.course_id.to_s + ")")
    end

    @events = @events.search(params[:search]).order(sort_column + " " + sort_direction).paginate(:per_page => 10, :page => params[:page])
  end

#User is able to mark a event, he wants to join. 
#if the user is logged in he can mark a event through the show-view.
  def mark_event
    event = Event.find(params[:id])
    #semester = params[:semester]
    unless current_user.nil?
      if (event.events_users.where(user_id: current_user.id).first.nil?)
      event.users << current_user
      cu = event.events_users.where(user_id: current_user.id).first
      cu.semester = params[:semester]
      cu.save!
      else
        cu = event.events_users.where(user_id: current_user.id).first
        cu.semester = params[:semester]
        cu.save!
        end

      redirect_to event_path(event)
    else
      redirect_to event_path(event), alert: "Nicht eingeloggt"
    end
  end


  def demark_event
    event = Event.find(params[:id])
    event.events_users.where(user_id: current_user.id).first.destroy
    redirect_to event_path(event), notice: "Veranstaltung wieder abgewählt!"

  end

  # GET /events/1
  # GET /events/1.json
  def show
    authorize! :show, @events
    @id = params[:id]
    puts 1
  end

  # GET /events/new
  def new
    authorize! :new, @events
    @event = Event.new
  end

  # POST /events
  # POST /events.json
  def create
    authorize! :create, @events
    @event = Event.new(event_params.except!("schedules"))
    
    respond_to do |format|
      if @event.save
        schedules = event_params[:schedules]
        event_params[:schedules].each do |sched|
          if @event.cycle == "Nicht regelmäßig"
            if sched != ""
              Schedule.create!(date: sched, event_id: @event.id)
            end
          end
        end
        format.html { redirect_to @event, notice: 'Veranstaltung wurde erfolgreich erstellt.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    authorize! :update, @events
    respond_to do |format|
      schedules = event_params[:schedules]
      # delete old schedules to avoid duplicates
      Schedule.where(event_id: @event.id).destroy_all

      event_params[:schedules].each do |sched|
        Schedule.create(date: sched, event_id: @event.id)
      end
      if @event.update(event_params.except!("schedules"))
        format.html { redirect_to @event, notice: 'Veranstaltung wurde erfolgreich geändert.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    authorize! :destroy, @events
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Veranstaltung wurde erfolgreich gelöscht.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:id, :identifier, :title, :description, :prof, :credits, :sws, :cycle, :next, :exam_type, :condition,  :schedules => [], :events_users_attributes => [:semester])
    end

    #sort events
    def sort_column
      Event.column_names.include?(params[:sort]) ? params[:sort] : "title"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
   
end

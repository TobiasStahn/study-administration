class RatingsController < ApplicationController
  #creates the rating for the event, and response in Json-Format

  def index
    authorize! :index, @rating
    @event = Event.all
  end

  def create
    authorize! :create, @rating
    @rating = Rating.new(params[:rating])
    @event = Event.find(params[:rating][:event_id])

    respond_to do |format|
        if @rating.save
          format.json { render :json => { :avg_rating => @event.avg_rating } }
        else
          format.json { render :json => @rating.errors, :status => :unprocessable_entity }
        end
    end
  end

  #defines the update-Method for the shown stars
  def update
    authorize! :update, @rating
    @rating = Rating.find(params[:id])
    @event = Event.find(params[:rating][:event_id])

    @rating.send(params[:column].to_sym, params[:rating])
    respond_to do |format|
      if @rating.save
        format.json { render :json => { :avg_rating => @event.avg_rating } }
      else
        format.json { render :json => @rating.errors, :status => :unprocessable_entity }
      end
    end
  end

  def rating
    @rating = Rating.find(params[:rating_id])
    @rating.send("#{params[:column]}=", params[:stars])
 
    respond_to do |format|
      if @rating.save
        format.json {
          render :json => {
            success: true
          }
        }
      end
    end
  end

  def show
    authorize! :show, @rating
   @rating = Rating.find(params[:id])
   @event = Rating.find(params[:id]).event
   @user = current_user
  end

  private
    def ratings_params
      params.require(:rating).permit(:column,:user_id, :event_id)
    end
end

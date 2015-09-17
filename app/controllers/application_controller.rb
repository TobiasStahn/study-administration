class ApplicationController < ActionController::Base
  
rescue_from CanCan::AccessDenied do |exception|
	respond_to do |format|
		format.json {render nothing: true, status: :forbidden }
		format.html {redirect_to main_app.root_url, :alert => exception.message}
	end
end


  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  helper_method :get_current_semester_and_year_from_date, :convert_date_to_number
  protect_from_forgery with: :exception

def js_logged_in
  if(!logged_in?)
    flash[:error] = "Login erforderlich für Rating!"
    render :js => "window.location = '/login'"
  end
end

# proctected sites unauthorized users
 helper_method :not_authorized, :redirect_to_profile
 def not_authorized(text)
 	redirect_to root_path, alert: text
 end

def get_current_semester_and_year_from_date(time)
	#check intervals for winter- or summer-semester
	if (time.month.to_i < 4 or time.month.to_i  > 9)
		semester = "Wintersemester"
		#double if-clause to check which of both possible wintersemesters is meant.
		if (time.month.to_i < 4)
			year = " "+((time.year-1).to_s)+"/"+((time.year).to_s)
		else
			year = " "+((time.year).to_s)+"/"+((time.year+1).to_s)
		end
	elsif (time.month.to_i  > 3 and time.month.to_i  < 10)
		semester = "Sommersemester"
		year = " "+ (time.year).to_s
	end
	return semester + year
end	


def convert_date_to_number(string1)	
	curr_date = get_current_semester_and_year_from_date(Time.now)
	curr_sem= curr_date.split(" ")[0]
	if(curr_sem == "Sommersemester")
		curr_year= curr_date.split(" ")[1]
	else 
		curr_year = curr_date.split(" ")[1].split("/")[0]
	end
	sem = string1.split(" ")[0]
	if(sem == "Sommersemester")
		year= string1.split(" ")[1]
	else 
		year = string1.split(" ")[1].split("/")[0]
	end
	if (year < curr_year)
		return "bestanden"
	elsif ( year == curr_year)
		if(sem == curr_sem)
			return "geplant"
		elsif(sem != curr_sem)
			if(sem== "Wintersemester")
				return "geplant"
			else
				return "bestanden"
			end
		end
	elsif(year > curr_year)
		return "geplant"
	end 

 end	

 def redirect_to_profile
 	redirect_to profile_path(@user.profile)
 end

add_flash_types :my_flash

end


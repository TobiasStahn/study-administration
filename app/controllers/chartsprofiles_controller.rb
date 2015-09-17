class ChartsprofilesController < ApplicationController
	helper_method :executesql, :executesqlarray, :encrypt, :min_semester, :decrypt, :max_semester

	def index
    authorize! :index, @chartsprofiles
		
    @users = current_user
	end

	def decrypt(semester)
     data = semester.split(' ')
    
    zahl = data[1].split('/')
    split = [data[0], zahl[0] ] 
      if(data[0].eql? 'Wintersemester')
        split = ((zahl[0].to_i)*10)+5
      else 
        split = (zahl[0].to_i)*10
      end
    return split    
  end

  def encrypt(semester)
    if(semester%10 == 0)
      data =  "Sommersemester " + (semester/10).to_s
    else
      data = "Wintersemester " + (semester/10).to_s + "/" +((semester/10)+1).to_s
    end
    return data
  end

  def max_semester(semester)  
    max = decrypt(semester[0][0])  
    (1..semester.length-1).each do |i|
      if(decrypt(semester[i][0])> max)
        max = decrypt(semester[i][0])
      end
    end
    return max
  end

  def min_semester(semester)  
    min = decrypt(semester[0][0])  
    (1..semester.length-1).each do |i|
      if(decrypt(semester[i][0])< min)
        min = decrypt(semester[i][0])
      end
    end
    return min
  end

  def executesqlarray(query)
      records_result = ActiveRecord::Base.connection.execute(query)
      records_array = records_result.values
    return records_array
  end

  def executesql(query)
      records_result = ActiveRecord::Base.connection.execute(query)
      records= records_result.getvalue(0,0)
    return records
  end
end

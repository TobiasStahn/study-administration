#Javascript/coffeescript-Functions to set the rating if the page is loading 
#and to update the rating. 
#update_stars gets the parameters from the database and sets it to the view
#if a user performs a click on one of the stars, the rating is set and 
#is send to the database and the average-value gets updated. 
#
#

set_stars = (form_id, stars) ->
  i = 1
  while i <= 5
    if i <= stars
      $('#' + form_id + "_" + i.toString()).addClass 'on'
    else
      $('#' + form_id + "_" + i.toString()).removeClass 'on'
    i++
  return

$ ->
  $('.rating_star').click ->
    star = $(this)
    form_id = star.attr('data-form-id') 
    rating_id = star.attr('data-rating-id')
    stars = star.attr('data-stars')
    column = star.attr('data-column')
    $('#' + form_id + '_stars').val stars
    $.ajax
      type: 'post'
      url: "/ratings/rate"   
      dataType: 'json'   
      data: 
        rating_id: rating_id,
        stars: stars,
        column: column,
      success: (response) ->
        set_stars(form_id, stars)
        if response['avg_rating']
          $('#average_rating').text response['avg_rating']
        return
      error: (xhr, ajaxOptions, thrownError) ->
        alert thrownError
    return
  return
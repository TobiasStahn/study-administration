# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('#myModule').click ->
    if $('#check_modul').prop('checked')
      $('#check_modul').prop 'checked', false
    else
      $('#check_modul').prop 'checked', true
    return

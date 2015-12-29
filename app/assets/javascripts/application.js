// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require angular
//= require angular-animate
//= require angular-route
//= require angular-resource
//= require bootstrap-sprockets
//= require froala_editor.min
//= require lib/nouislider.min
//= require lib/owlcarousel
//= require places-form
//= require ngAutocomplete
//= require jquery.mockjax
//= require bootstrap-typeahead
//= require store_setting

function stickDropdown(_elem){
  $(_elem).parent().removeClass('open').addClass('open');
}
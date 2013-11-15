// dri.js
//
// Some javascript to improve array handling in the edit and new audios forms

// When the document has loaded run these functions
$(document).ready(function() {
  add_text_field();
  destroy_text_field();
});

// Whenever an "add" link is clicked, a new text field is added to the bottom of the list 
add_text_field = function() {
    $('.add-text-field a').click(function() {
      var fieldset_name = $(this).parent().parent().attr('id');
      var model_name = $(this).attr('model-name');
      $(this).parent().before(  
      '<input class="edit span6 dri-textfield" id="'+model_name+'_'+fieldset_name+'][" name="'+model_name+'['+fieldset_name+'][]" size="30" type="text" value=""> <a class="destructive">Delete</a><br />');
      $(this).parent().siblings('a').last().click(function() {
        $(this).prev('input[type="text"]').remove();
        $(this).prev('br').remove();
        $(this).remove();
        return false;
      });
      return false;
    });
  }

// Remove the text field and the "delete" button whenever the "delete" link is clicked
destroy_text_field = function() {
    $('.destructive').click(function() {
      var fieldset_name = $(this).parent().attr('id');
      var model_name = $(this).attr('model-name');
      $(this).prev('input[type="text"]').remove();
      $(this).prev('br').remove();
      $(this).before('<input type="hidden" id="'+model_name+'_'+fieldset_name+'][" name="'+model_name+'['+fieldset_name+'][]" value="">');
      $(this).remove();
      return false;
    });
}

// Adds audio player in asset display for audio file
$(document).ready(function() {  
    var audioSection = $('section#audio');  
    $('a.player').click(function() {  
        var audio = $('<audio>', {  
             controls : 'controls'  
        });  
        var url = $(this).attr('href');  
        $('<source>').attr('src', url).appendTo(audio);  
        audioSection.html(audio);  
        return false;  
    });  
});

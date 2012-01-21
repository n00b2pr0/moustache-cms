jQuery -> 
  $(document).ready ->
    if $('body.articles').length

      /* hide initial form elements */
      $('#advanced_fields legend').siblings().first().hide()
      $('#advanced_fields legend').find('span').removeClass('rotate')

      $('#meta_tags_fields legend').siblings().first().hide()
      $('#meta_tags_fields legend').find('span').removeClass('rotate')

      /* meta_tag remove new meta tag*/
      $('span.delete_new_meta_tag').live 'click', ->      
        $(this).parent().fadeToggle 'slow', 'linear', ->
          $(this).remove()
        false

      /* new article ajax add meta_tag */
      if $('p#meta_tag_message').length
        $('#meta_tag_message').remove()
        $('#add_meta_tag').append('<span class="fake_link">Add Meta Tag</span>')
        $('#add_meta_tag .fake_link').click ->
          $('#meta_tags_fieldset .spinner').ajaxStart ->
            $(this).removeClass('hidden')
          $('#meta_tags_fieldset .spinner').ajaxStop ->
            $(this).addClass('hidden')
          $.get '/admin/articles/new_meta_tag', ->

      /* meta_tag ajax spinner */
      $('#add_meta_tag').bind 'ajax:before', ->
        $('#meta_tags_fieldset .spinner').removeClass('hidden')
      $('#add_meta_tag').bind 'ajax:complete', ->
        $('#meta_tags_fieldset .spinner').addClass('hidden')

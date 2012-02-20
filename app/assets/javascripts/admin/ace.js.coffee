$(document).ready -> 

  root = global ? window

  class root.Mode
    constructor: (@name, @desc, @klass, extensions) ->
      @mode = new @klass()
      @extRe = new RegExp("^.*\\.(" + extensions.join("|") + ")$", "g")

  class root.HandlebarEditor
    constructor: (args) ->
      @options = $.extend({ 
        tabSize: 2
        useWrapMode: false
        wrapLimit: NaN
        printMargin: 80
        filter: 'html'
      }, args)

      @elementId = args.elementId
      @element = $('#' + @elementId)
      @editor = ace.edit @elementId
      @editor.setTheme "ace/theme/twilight"
      @editor.session.setUseWrapMode @options.useWrapMode
      @editor.session.setWrapLimitRange @options.wrapLimit, @options.wrapLimit
      @editor.session.setTabSize @options.tabSize
      @editor.session.setUseSoftTabs true
      @editor.renderer.setPrintMarginColumn @options.printMargin
      @editor.renderer.setShowPrintMargin false
      @contentSettings @options.filter
      @hideUpdateTextarea()

    @modes = [  
      new Mode("css", "CSS", ace.require("ace/mode/css").Mode, ["css"]),
      new Mode("html", "HTML", ace.require("ace/mode/html").Mode, ["html", "htm"]),
      new Mode("javascript", "JavaScript", ace.require("ace/mode/javascript").Mode, ["js"]),
      new Mode("markdown", "Markdown", ace.require("ace/mode/markdown").Mode, ["md", "markdown"]),
      new Mode("textile", "Textile", ace.require("ace/mode/textile").Mode, ["textile"])
      ]

    @modesByName: {}
    for mode in @modes
      @modesByName[mode.name] = mode

    @editors: []

    contentSettings: (filterText) ->
      @editor.getSession().setMode HandlebarEditor.modesByName[filterText].mode
      @editor.getSession().setMode HandlebarEditor.modesByName[filterText].mode

    # on form submit update hidden textarea with ace editor content
    hideUpdateTextarea: ->
      $('.content_submit').hide()
      #update hidden textarea
      $('.site_prop').submit =>
        @element.parent().next().find('textarea').val @editor.getSession().getValue()

    createEditor: (elementId) ->
      @editor = ace.edit elementId
      @editor.setTheme "ace/theme/twilight"

    toString: ->
      'elementId =' + @elementId + ' ' +
      'element =' + @element.toString() + ' ' +
      'editor =' + @editor.toString()

  if $("body.layouts #layout_content").length
    hbEditor = new HandlebarEditor elementId: "layout_content", filter: 'html'

  else if $("body.snippets #snippet_content").length
    hbEditor = new HandlebarEditor elementId: 'snippet_content', filter: $('#snippet_filter_name').val()
    $('#snippet_filter_name').change ->
      hbEditor.contentSettings $(@).val()

  else if $("body.articles #article_content").length
    hbEditorSub = new HandlebarEditor elementId: "article_subheading_content", filter: $('#article_filter_name')
    hbEditorContent = new HandlebarEditor elemntId: "article_content", filter: $('#article_filter_name')
    $('#article_filter_name').change ->
      hbEditorSub.contentSettings $(@).val()
      hbEditorContent.contentSettings $(@).val() 

  else if $("body.theme_assets #theme_asset_content").length
    if $('li.css_asset')
      hbEditor = new HandlebarEditor elementId: 'theme_asset_content', filter: 'css'
    else if $('li.js_asset')
      hbEditor = new HandlebarEditor elementId: 'theme_asset_content', filter: 'javascript'
    
  else if $("body.pages .page_parts").length
    filters = []
    $('.page_part_filter').each -> 
      filters.push @

    HandlebarEditor.editors = [] 
    $('.page_part_content').each (index) ->
      editor = new HandlebarEditor  { elementId: @.id, filter: $(filters[index]).val() }
      HandlebarEditor.editors.push editor

    # hide all page parts that are not selected 
    # after adding editor to view otherwise they don't render correctly
    $('ol.page_part').each ->
      $(@).hide()

    $('.page_part_filter').on 'change', ->
      editor = HandlebarEditor.editors[$('.page_part_filter').index(@)]
      editor.contentSettings $(@).val()
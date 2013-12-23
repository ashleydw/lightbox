###
Lightbox for Bootstrap 3 by @ashleydw
https://github.com/ashleydw/lightbox

License: https://github.com/ashleydw/lightbox/blob/master/LICENSE
###
"use strict";

EkkoLightbox = ( element, options ) ->

	@options = $.extend({
		gallery_parent_selector: '*:not(.row)'
		title : null
		footer : null
		remote : null
		left_arrow_class: '.glyphicon .glyphicon-chevron-left' #include class . here - they are stripped out later
		right_arrow_class: '.glyphicon .glyphicon-chevron-right' #include class . here - they are stripped out later
		directional_arrows: true #display the left / right arrows or not
		type: null #force the lightbox into image / youtube mode. if null, or not image|youtube|vimeo; detect it
		onShow : ->
		onShown : ->
		onHide : ->
		onHidden : ->
		id : false
	}, options || {})

	@$element = $(element)
	content = ''

	@modal_id = if @options.modal_id then @options.modal_id else 'ekkoLightbox-' + Math.floor((Math.random() * 1000) + 1)
	header = '<div class="modal-header"'+(if @options.title then '' else ' style="display:none"')+'><button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button><h4 class="modal-title">' + @options.title + '</h4></div>'
	footer = '<div class="modal-footer"'+(if @options.footer then '' else ' style="display:none"')+'>' + @options.footer + '</div>'
	$(document.body).append '<div id="' + @modal_id + '" class="ekko-lightbox modal fade" tabindex="-1"><div class="modal-dialog"><div class="modal-content">' + header + '<div class="modal-body"><div class="ekko-lightbox-container"><div></div></div></div>' + footer + '</div></div></div>'

	@modal = $ '#' + @modal_id
	@modal_body = @modal.find('.modal-body').first()
	@lightbox_container = @modal_body.find('.ekko-lightbox-container').first()
	@lightbox_body = @lightbox_container.find('> div:first-child').first()
	@modal_arrows = null

	@padding = {
		left: parseFloat(@modal_body.css('padding-left'), 10)
		right: parseFloat(@modal_body.css('padding-right'), 10)
		bottom: parseFloat(@modal_body.css('padding-bottom'), 10)
		top: parseFloat(@modal_body.css('padding-top'), 10)
	}

	if !@options.remote
		@error 'No remote target given'
	else

		@gallery = @$element.data('gallery')
		if @gallery
			# parents('document.body') fails for some reason, so do this manually
			if this.options.gallery_parent_selector == 'document.body' || this.options.gallery_parent_selector == ''
				@gallery_items = $(document.body).find('*[data-toggle="lightbox"][data-gallery="' + @gallery + '"]')
			else
				@gallery_items = @$element.parents(this.options.gallery_parent_selector).first().find('*[data-toggle="lightbox"][data-gallery="' + @gallery + '"]')
			@gallery_index = @gallery_items.index(@$element)
			$(document).on 'keydown.ekkoLightbox', @navigate.bind(@)

			# add the directional arrows to the modal
			if @options.directional_arrows && @gallery_items.length > 1
				@lightbox_container.prepend('<div class="ekko-lightbox-nav-overlay"><a href="#" class="'+@strip_stops(@options.left_arrow_class)+'"></a><a href="#" class="'+@strip_stops(@options.right_arrow_class)+'"></a></div>')
				@modal_arrows = @lightbox_container.find('div.ekko-lightbox-nav-overlay').first()
				@lightbox_container.find('a'+@strip_spaces(@options.left_arrow_class)).on 'click', (event) =>
					event.preventDefault()
					do @navigate_left
				@lightbox_container.find('a'+@strip_spaces(@options.right_arrow_class)).on 'click', (event) =>
					event.preventDefault()
					do @navigate_right

		if @options.type
			if @options.type == 'image'
				@preloadImage(@options.remote, true)
			else if @options.type == 'youtube' && video_id = @getYoutubeId(@options.remote)
				@showYoutubeVideo(video_id)
			else if @options.type == 'vimeo'
				@showVimeoVideo(@options.remote)
			else
				@error "Could not detect remote target type. Force the type using data-type=\"image|youtube|vimeo\""

		else
			@detectRemoteType(@options.remote)


	@modal
		.on('show.bs.modal', @options.onShow.bind(@))
		.on 'shown.bs.modal', =>
			if @modal_arrows
				@resize @lightbox_body.width()
			@options.onShown.call(@)
		.on('hide.bs.modal', @options.onHide.bind(@))
		.on 'hidden.bs.modal', =>
			if @gallery
				$(document).off 'keydown.ekkoLightbox'
			@modal.remove()
			@options.onHidden.call(@)
		.modal 'show', options

	@modal

EkkoLightbox.prototype = {
	strip_stops: (str) ->
		str.replace(/\./g, '')

	strip_spaces: (str) ->
		str.replace(/\s/g, '')

	isImage: (str) ->
		str.match(/(^data:image\/.*,)|(\.(jp(e|g|eg)|gif|png|bmp|webp|svg)((\?|#).*)?$)/i)

	isSwf: (str) ->
		str.match(/\.(swf)((\?|#).*)?$/i)

	getYoutubeId: (str) ->
		match = str.match(/^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/);
		if match && match[2].length == 11 then match[2] else false

	getVimeoId: (str) ->
		if str.indexOf('vimeo') > 0 then str else false

	navigate : ( event ) ->

		event = event || window.event;
		if event.keyCode == 39 || event.keyCode == 37
			if event.keyCode == 39
				do @navigate_right
			else if event.keyCode == 37
				do @navigate_left

	navigate_left: ->

		if @gallery_index == 0 then @gallery_index = @gallery_items.length-1 else @gallery_index-- #circular

		@$element = $(@gallery_items.get(@gallery_index))
		@updateTitleAndFooter()
		src = @$element.attr('data-remote') || @$element.attr('href')

		@detectRemoteType(src, @$element.attr('data-type'))

	navigate_right: ->

		if @gallery_index == @gallery_items.length-1 then @gallery_index = 0 else @gallery_index++ #circular

		@$element = $(@gallery_items.get(@gallery_index))
		src = @$element.attr('data-remote') || @$element.attr('href')
		@updateTitleAndFooter()

		@detectRemoteType(src, @$element.attr('data-type'))

		if @gallery_index + 1 < @gallery_items.length
			next = $(@gallery_items.get(@gallery_index + 1), false)
			src = next.attr('data-remote') || next.attr('href')
			if @isImage(src)
				@preloadImage(src, false)

	detectRemoteType: (src, type) ->
		if type == 'image' || @isImage(src)
			@preloadImage(src, true)
		else if type == 'youtube' || video_id = @getYoutubeId(src)
			@showYoutubeVideo(video_id)
		else if type == 'vimeo' || video_id = @getVimeoId(src)
			@showVimeoVideo(video_id)
		else
			@error "Could not detect remote target type. Force the type using data-type=\"image|youtube|vimeo\""

	updateTitleAndFooter: ->
		header = @modal.find('.modal-dialog .modal-content .modal-header')
		footer = @modal.find('.modal-dialog .modal-content .modal-footer')
		title = @$element.data('title') || ""
		caption = @$element.data('footer') || ""
		if title then header.css('display', '').find('.modal-title').html(title) else header.css('display', 'none')
		if caption then footer.css('display', '').html(caption) else footer.css('display', 'none')
		@

	showLoading : ->
		@lightbox_body.html '<div class="modal-loading">Loading..</div>'
		@

	showYoutubeVideo : (id) ->
		@resize 560
		@lightbox_body.html '<iframe width="560" height="315" src="//www.youtube.com/embed/' + id + '?badge=0&autoplay=1" frameborder="0" allowfullscreen></iframe>'
		if @modal_arrows #hide the arrows when showing video
			@modal_arrows.css 'display', 'none'

	showVimeoVideo : (id) ->
		@resize 500
		@lightbox_body.html '<iframe width="500" height="281" src="' + id + '?autoplay=1" frameborder="0" allowfullscreen></iframe>'
		if @modal_arrows #hide the arrows when showing video
			@modal_arrows.css 'display', 'none'

	error : ( message ) ->
		@lightbox_body.html message
		@

	preloadImage : ( src, onLoadShowImage) ->

		img = new Image()
		if !onLoadShowImage? || onLoadShowImage == true
			img.onload = =>
				width = @checkImageDimensions(img.width)
				image = $('<img />')
				image.attr('src', img.src)
				image.css('max-width', '100%')
				@lightbox_body.html image
				if @modal_arrows #show the arrows
					@modal_arrows.css 'display', 'block'
				@resize width
			img.onerror = =>
				@error 'Failed to load image: ' + src

		img.src = src
		img

	resize : ( width ) ->
		width_inc_padding = width + @padding.left + @padding.right
		@modal.find('.modal-content').css('width', width_inc_padding)
		@modal.find('.modal-dialog').css('width', width_inc_padding + 20 ) #+ 20 because of the drop shadow
		# fu padding, fu
		@lightbox_container.find('a').css 'padding-top', ->
			$(@).parent().height() / 2
		@

	checkImageDimensions: (max_width) ->
		#resize the container based on the max width given
		w = $(window)
		width = max_width
		if (max_width + (@padding.left + @padding.right + 20)) > w.width()
			width = w.width() - (@padding.left + @padding.right + 20) #+ 20 because of the drop shadow
		width

	close : ->
		@modal.modal('hide');
}


$.fn.ekkoLightbox = ( options ) ->
	@each ->

		$this = $(this)
		options = $.extend({
			remote : $this.attr('data-remote') || $this.attr('href')
			gallery_parent_selector : $this.attr('data-parent')
			type : $this.attr('data-type')
		}, options, $this.data())
		new EkkoLightbox(@, options)
		@

$(document).delegate '*[data-toggle="lightbox"]', 'click', ( event ) ->
	event.preventDefault()

	$this = $(this)
	$this
		.ekkoLightbox({
			remote : $this.attr('data-remote') || $this.attr('href')
			gallery_parent_selector : $this.attr('data-parent')
			onShown: ->
				if window.console
					console.log('Checking our the events huh?')
		})
		.one 'hide', ->
			$this.is(':visible') && $this.focus()

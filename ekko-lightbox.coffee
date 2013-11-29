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
		onShow : ->
		onShown : ->
		onHide : ->
		onHidden : ->
			if @gallery
				$(document).off 'keydown.ekkoLightbox'
			@modal.remove()
		id : false
	}, options || {})

	@$element = $(element)
	content = ''

	@modal_id = if @options.modal_id then @options.modal_id else 'ekkoLightbox-' + Math.floor((Math.random() * 1000) + 1)
	header = '<div class="modal-header"'+(if @options.title then '' else ' style="display:none"')+'><button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button><h4 class="modal-title">' + @options.title + '</h4></div>'
	footer = '<div class="modal-footer"'+(if @options.footer then '' else ' style="display:none"')+'>' + @options.footer + '</div>'
	$(document.body).append '<div id="' + @modal_id + '" class="ekko-lightbox modal fade" tabindex="-1"><div class="modal-dialog"><div class="modal-content">' + header + '<div class="modal-body"><div class="ekko-lightbox-container"></div></div>' + footer + '</div></div></div>'

	@modal = $ '#' + @modal_id
	@modal_body = @modal.find('.modal-body').first()
	@lightbox_body = @modal_body.find('.ekko-lightbox-container').first()
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

		if @isImage(@options.remote)
			@preloadImage(@options.remote, true)

		else if youtube = @getYoutubeId(@options.remote)
			@showYoutubeVideo(youtube)

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
			if @options.directional_arrows
				arrows = '<div class="ekko-lightbox-nav-overlay"><a href="#" class="'+@strip_stops(@options.left_arrow_class)+'"></a><a href="#" class="'+@strip_stops(@options.right_arrow_class)+'"></a></div>';
				@modal_body.prepend(arrows)
				@modal_arrows = @modal_body.find('.ekko-lightbox-nav-overlay').first()
				@modal_arrows.find('a'+@strip_spaces(@options.left_arrow_class)).on 'click', (event) =>
					event.preventDefault()
					do @navigate_left
				@modal_arrows.find('a'+@strip_spaces(@options.right_arrow_class)).on 'click', (event) =>
					event.preventDefault()
					do @navigate_right


	@modal
		.on('show.bs.modal', @options.onShow.bind(@))
		.on('shown.bs.modal', @options.onShown.bind(@))
		.on('hide.bs.modal', @options.onHide.bind(@))
		.on('hidden.bs.modal', @options.onHidden.bind(@))
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
		src = @$element.attr('data-source') || @$element.attr('href')

		if @isImage(src)
			@preloadImage(src, true)
		else if youtube = @getYoutubeId(src)
			@showYoutubeVideo(youtube)

	navigate_right: ->

		if @gallery_index == @gallery_items.length-1 then @gallery_index = 0 else @gallery_index++ #circular

		@$element = $(@gallery_items.get(@gallery_index))
		src = @$element.attr('data-source') || @$element.attr('href')
		@updateTitleAndFooter()

		if @isImage(src)
			@preloadImage(src, true)
		else if youtube = @getYoutubeId(src)
			@showYoutubeVideo(youtube)

		if @gallery_index + 1 < @gallery_items.length
			next = $(@gallery_items.get(@gallery_index + 1), false)
			src = next.attr('data-source') || next.attr('href')
			if @isImage(src)
				@preloadImage(src, false)

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
		@resize(560, 315)
		@lightbox_body.html '<iframe width="560" height="315" src="//www.youtube.com/embed/' + id + '?autoplay=1" frameborder="0" allowfullscreen></iframe>'

	error : ( message ) ->
		@lightbox_body.html message
		@

	preloadImage : ( src, onLoadShowImage) ->

		img = new Image()
		if !onLoadShowImage? || onLoadShowImage == true
			img.onload = =>
				width = img.width
				@checkImageDimensions(img)
				@lightbox_body.html img
				@resize width, img.height
			img.onerror = =>
				@error 'Failed to load image: ' + src

		img.src = src
		img

	close : ->
		@modal.modal('hide');

	resize : ( width, height ) ->
		width_inc_padding = width + @padding.left + @padding.right
		@modal.find('.modal-content').css {
			'width' : width_inc_padding
		}
		@modal.find('.modal-dialog').css {
			'width' : width_inc_padding + 20 #+ 20 because of the drop shadow
		}
		if @modal_arrows
			@modal_arrows.css {
				'width' : width
				'height': height
			}
		@

	checkImageDimensions: (img) ->

		w = $(window)
		if (img.width + (@padding.left + @padding.right + 20)) > w.width()
			img.width = w.width() - (@padding.left + @padding.right + 20) #+ 20 because of the drop shadow
		img.width

}


$.fn.ekkoLightbox = ( options ) ->
	@each ->

		$this = $(this)
		options = $.extend({
			remote : $this.attr('data-source') || $this.attr('href')
			gallery_parent_selector : $this.attr('data-parent')
		}, $this.data())
		new EkkoLightbox(@, options)
		@

$(document).delegate '*[data-toggle="lightbox"]', 'click', ( event ) ->
	event.preventDefault()

	$this = $(this)
	$this
		.ekkoLightbox({
			remote : $this.attr('data-source') || $this.attr('href')
			gallery_parent_selector : $this.attr('data-parent')
		})
		.one 'hide', ->
			$this.is(':visible') && $this.focus()

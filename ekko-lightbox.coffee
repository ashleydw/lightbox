###
Lightbox for Bootstrap 3 by @ashleydw
https://github.com/ashleydw/lightbox

License: https://github.com/ashleydw/lightbox/blob/master/LICENSE
###
EkkoLightbox = ( element, options ) ->

	@options = $.extend({
		title : null
		footer : null
		remote : null
		keyboard : true
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
	header = if @options.title then '<div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button><h4 class="modal-title">' + @options.title + '</h4></div>' else ''
	footer = if @options.footer then '<div class="modal-footer">' + @options.footer + '</div>' else ''
	$(document.body).append '<div id="' + @modal_id + '" class="modal fade" tabindex="-1"><div class="modal-dialog"><div class="modal-content">' + header + '<div class="modal-body"></div>' + footer + '</div></div></div>'

	@modal = $ '#' + @modal_id
	@modal_body = @modal.find('.modal-body').first()

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

		else if @isSwf(@options.remote)
			console.log('todo')

		@gallery = @$element.data('gallery')
		if @gallery
			@gallery_items = @$element.parents('*:not(.row)').first().find('*[data-toggle="lightbox"][data-gallery="' + @gallery + '"]')
			@gallery_index = @gallery_items.index(@$element)
			$(document).on 'keydown.ekkoLightbox', @navigate.bind(@)

	@modal
		.on('show.bs.modal', @options.onShow.bind(@))
		.on('shown.bs.modal', @options.onShown.bind(@))
		.on('hide.bs.modal', @options.onHide.bind(@))
		.on('hidden.bs.modal', @options.onHidden.bind(@))
		.modal 'show', options

	@modal

EkkoLightbox.prototype = {
	isImage: (str) ->
		str.match(/(^data:image\/.*,)|(\.(jp(e|g|eg)|gif|png|bmp|webp|svg)((\?|#).*)?$)/i)
	isSwf: (str) ->
		str.match(/\.(swf)((\?|#).*)?$/i)
	getYoutubeId: (str) ->
		match = str.match(/^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/);
		return if match && match[2].length == 11 then match[2] else false

	navigate : ( event ) ->
		event = event || window.event;

		if event.keyCode == 39 || event.keyCode == 37

			if event.keyCode == 39 && @gallery_index + 1 < @gallery_items.length
				@gallery_index++
				@$element = $(@gallery_items.get(@gallery_index))
				src = @$element.attr('data-source') || @$element.attr('href')
				if @isImage(src)
					@preloadImage(src, true)
				else if youtube = @getYoutubeId(src)
					@showYoutubeVideo(youtube)

				if @gallery_index + 1 < @gallery_items.length
					next = $(@gallery_items.get(@gallery_index + 1), false)
					src = next.attr('data-source') || next.attr('href')
					if @isImage(src)
						@preloadImage(src, false)

			else if event.keyCode == 37 && @gallery_index > 0
				@gallery_index--
				@$element = $(@gallery_items.get(@gallery_index))
				src = @$element.attr('data-source') || @$element.attr('href')
				if @isImage(src)
					@preloadImage(src, true)
				else if youtube = @getYoutubeId(src)
					@showYoutubeVideo(youtube)

	showLoading : ->
		@modal_body.html '<div class="modal-loading">Loading..</div>'

	showYoutubeVideo : (id) ->
		@resize(560, 315)
		@modal_body.html '<iframe width="560" height="315" src="//www.youtube.com/embed/' + id + '?autoplay=1" frameborder="0" allowfullscreen></iframe>'

	error : ( message ) ->
		@modal_body.html message

	preloadImage : ( src, onLoadShowImage) ->

		img = new Image()
		if !onLoadShowImage? || onLoadShowImage == true
			img.onload = =>
				@checkImageDimensions(img)
				@modal_body.html img
				i = @modal_body.find('img').first()
				width = if i && i.width() > 0 then i.width() else img.width
				@resize width, i.height()
			img.onerror = =>
				@error 'Failed to load image: ' + src

		img.src = src

	close : ->
		@modal.modal('hide');

	center: ->
		@modal.find('.modal-dialog').css({
			'left': -> -($(this).width()/2)
		})

	resize : ( width, height ) ->
		width = width + @padding.left + @padding.right
		#height = height + @padding.top + @padding.bottom
		@modal.find('.modal-content').css {
			'width' : width
		}
		@modal.find('.modal-dialog').css {
			'width' : width + 20 #+ 20 because of the drop shadow
		}
		do @center

	checkImageDimensions: (img) ->

		w = $(window)
		if (img.width + (@padding.left + @padding.right + 20)) > w.width()
			img.width = w.width() - (@padding.left + @padding.right + 20) #+ 20 because of the drop shadow

}


$.fn.ekkoLightbox = ( options ) ->
	@each ->

		$this = $(this)
		new EkkoLightbox(@, { remote : $this.attr('data-source') || $this.attr('href') })
		@

$(document).delegate '*[data-toggle="lightbox"]', 'click', ( event ) ->
	event.preventDefault()

	$this = $(this)
	$this
		.ekkoLightbox({ remote : $this.attr('data-source') || $this.attr('href') })
		.one 'hide', ->
			$this.is(':visible') && $this.focus()
'use strict';

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ('value' in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError('Cannot call a class as a function'); } }

var Lightbox = (function ($) {

	var NAME = 'ekkoLightbox';
	var JQUERY_NO_CONFLICT = $.fn[NAME];

	var Default = {
		title: '',
		footer: '',
		left_arrow_class: '.glyphicon .glyphicon-chevron-left', //include class . here - they are stripped out later
		right_arrow_class: '.glyphicon .glyphicon-chevron-right', //include class . here - they are stripped out later
		directional_arrows: true, //display the left / right arrows or not
		type: null, //force the lightbox into image / youtube mode. if null, or not image|youtube|vimeo; detect it
		always_show_close: true, //always show the close button, even if there is no title
		scale_height: true, //scales height and width if the image is taller than window size
		loadingMessage: 'Loading...',
		onShow: function onShow() {},
		onShown: function onShown() {},
		onHide: function onHide() {},
		onHidden: function onHidden() {},
		onNavigate: function onNavigate() {},
		onContentLoaded: function onContentLoaded() {}
	};

	var Lightbox = (function () {
		_createClass(Lightbox, null, [{
			key: 'Default',

			/**
    
      Class properties:
    
    _$element: null -> the <a> element currently being displayed
    _$modal: The bootstrap modal generated
       _$modalDialog: The .modal-dialog
       _$modalContent: The .modal-content
       _$modalBody: The .modal-body
       _$modalHeader: The .modal-header
       _$modalFooter: The .modal-footer
    _$lightboxContainer: Container of the lightbox element
    _$lightboxBody: First element in the container
    _$modalArrows: The overlayed arrows container
   	 _$galleryItems: Other <a>'s available for this gallery
    _galleryName: Name of the current data('gallery') showing
    _galleryIndex: The current index of the _$galleryItems being shown
   	 _config: {} the options for the modal
    _modalId: unique id for the current lightbox
    _padding / _border: CSS properties for the modal container; these are used to calculate the available space for the content
   	 */

			get: function get() {
				return Default;
			}
		}]);

		function Lightbox($element, config) {
			var _this = this;

			_classCallCheck(this, Lightbox);

			this._config = $.extend({}, Default, config);
			this._$modalArrows = null;
			this._galleryIndex = 0;
			this._galleryName = null;
			this._padding = null;
			this._border = null;
			this._modalId = 'ekkoLightbox-' + Math.floor(Math.random() * 1000 + 1);
			this._$element = $element instanceof jQuery ? $element : $($element);

			var header = '<div class="modal-header"' + (this._config.title || this._config.always_show_close ? '' : ' style="display:none"') + '><button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button><h4 class="modal-title">' + (this._config.title || "&nbsp;") + '</h4></div>';
			var footer = '<div class="modal-footer"' + (this._config.footer ? '' : ' style="display:none"') + '>' + (this._config.footer || "&nbsp;") + '</div>';
			var body = '<div class="modal-body"><div class="ekko-lightbox-container"><div></div></div></div>';
			$(document.body).append('<div id="' + this._modalId + '" class="ekko-lightbox modal fade" tabindex="-1" tabindex="-1" role="dialog" aria-hidden="true"><div class="modal-dialog" role="document"><div class="modal-content">' + header + body + footer + '</div></div></div>');

			this._$modal = $('#' + this._modalId);
			this._$modalDialog = this._$modal.find('.modal-dialog').first();
			this._$modalContent = this._$modal.find('.modal-content').first();
			this._$modalBody = this._$modal.find('.modal-body').first();
			this._$modalHeader = this._$modal.find('.modal-header').first();
			this._$modalFooter = this._$modal.find('.modal-footer').first();

			this._$lightboxContainer = this._$modalBody.find('.ekko-lightbox-container').first();
			this._$lightboxBody = this._$lightboxContainer.find('> div:first-child').first();

			this._showLoading();

			this._border = this._calculateBorders();
			this._padding = this._calculatePadding();

			this._galleryName = this._$element.data('gallery');
			if (this._galleryName) {
				this._$galleryItems = $(document.body).find('*[data-gallery="' + this._galleryName + '"]');
				this._galleryIndex = this._$galleryItems.index(this._$element);
				$(document).on('keydown.ekkoLightbox', this._navigationalBinder.bind(this));

				// add the directional arrows to the modal
				if (this._config.directional_arrows && this._$galleryItems.length > 1) {
					this._$lightboxContainer.append('<div class="ekko-lightbox-nav-overlay"><a href="#" class="' + this._stripStops(this._config.left_arrow_class) + '"></a><a href="#" class="' + this._stripStops(this._config.right_arrow_class) + '"></a></div>');
					this._$modalArrows = this._$lightboxContainer.find('div.ekko-lightbox-nav-overlay').first();
					this._$lightboxContainer.find('a' + this._stripSpaces(this._config.left_arrow_class)).on('click', function (event) {
						event.preventDefault();
						return _this.navigateLeft();
					});
					this._$lightboxContainer.find('a' + this._stripSpaces(this._config.right_arrow_class)).on('click', function (event) {
						event.preventDefault();
						return _this.navigateRight();
					});
				}
			}

			this._$modal.on('show.bs.modal', this._config.onShow.bind(this)).on('shown.bs.modal', function () {
				_this._handle();
				return _this._config.onShown.call(_this);
			}).on('hide.bs.modal', this._config.onHide.bind(this)).on('hidden.bs.modal', function () {
				if (_this._galleryName) $(document).off('keydown.ekkoLightbox');
				_this._$modal.remove();
				return _this._config.onHidden.call(_this);
			}).modal(this._config);
		}

		_createClass(Lightbox, [{
			key: 'element',
			value: function element() {
				return this._$element;
			}
		}, {
			key: 'modal',
			value: function modal() {
				return this._$modal;
			}
		}, {
			key: 'navigateTo',
			value: function navigateTo(index) {

				if (index < 0 || index > this._$galleryItems.length - 1) return this;

				this._showLoading();

				this._galleryIndex = index;

				this._$element = $(this._$galleryItems.get(this._galleryIndex));
				this._handle();

				if (this._galleryIndex + 1 < this._$galleryItems.length) {
					var next = $(this._$galleryItems.get(this._galleryIndex + 1), false);
					var src = next.attr('data-remote') || next.attr('href');
					if (next.attr('data-type') === 'image' || this._isImage(src)) return this._preloadImage(src, false);
				}
			}
		}, {
			key: 'navigateLeft',
			value: function navigateLeft() {

				if (this._$galleryItems.length === 1) return;

				if (this._galleryIndex === 0) this._galleryIndex = this._$galleryItems.length - 1;else //circular
					this._galleryIndex--;

				this._config.onNavigate.call(this, 'left', this._galleryIndex);
				return this.navigateTo(this._galleryIndex);
			}
		}, {
			key: 'navigateRight',
			value: function navigateRight() {

				if (this._$galleryItems.length === 1) return;

				if (this._galleryIndex === this._$galleryItems.length - 1) this._galleryIndex = 0;else //circular
					this._galleryIndex++;

				this._config.onNavigate.call(this, 'right', this._galleryIndex);
				return this.navigateTo(this._galleryIndex);
			}
		}, {
			key: 'close',
			value: function close() {
				return this._$modal.modal('hide');
			}
		}, {
			key: 'resize',
			value: function resize(width) {
				var _this2 = this;

				//resize the dialog based on the width given, and adjust the directional arrow padding
				var width_total = width + this._border.left + this._padding.left + this._padding.right + this._border.right;
				this._$modalDialog.css('width', 'auto').css('maxWidth', width_total);

				this._$lightboxContainer.find('a').css('line-height', function () {
					return $(_this2).parent().height() + 'px';
				});
				return this;
			}

			// helper private methods
		}, {
			key: '_navigationalBinder',
			value: function _navigationalBinder(event) {
				event = event || window.event;
				if (event.keyCode === 39) return this.navigateRight();
				if (event.keyCode === 37) return this.navigateLeft();
			}
		}, {
			key: '_stripStops',
			value: function _stripStops(str) {
				return str.replace(/\./g, '');
			}
		}, {
			key: '_stripSpaces',
			value: function _stripSpaces(str) {
				return str.replace(/\s/g, '');
			}

			// type detection private methods
		}, {
			key: '_detectRemoteType',
			value: function _detectRemoteType(src, type) {

				type = type || false;

				if (!type && this._isImage(src)) type = 'image';
				if (!type && this._getYoutubeId(src)) type = 'youtube';
				if (!type && this._getVimeoId(src)) type = 'vimeo';
				if (!type && this._getInstagramId(src)) type = 'instagram';

				if (!type || ['image', 'youtube', 'vimeo', 'instagram', 'video', 'url'].indexOf(type) < 0) type = 'url';

				return type;
			}
		}, {
			key: '_handle',
			value: function _handle() {

				this._updateTitleAndFooter();

				var currentRemote = this._$element.attr('data-remote') || this._$element.attr('href');
				var currentType = this._detectRemoteType(currentRemote, this._$element.attr('data-type') || false);

				if (['image', 'youtube', 'vimeo', 'instagram', 'video', 'url'].indexOf(currentType) < 0) return this._error("Could not detect remote target type. Force the type using data-type=\"image|youtube|vimeo|instagram|url|video\"");

				switch (currentType) {
					case 'image':
						return this._preloadImage(currentRemote, true);
						break;
					case 'youtube':
						return this._showYoutubeVideo(currentRemote);
						break;
					case 'vimeo':
						return this._showVimeoVideo(this._getVimeoId(currentRemote));
						break;
					case 'instagram':
						return this._showInstagramVideo(this._getInstagramId(currentRemote));
						break;
					case 'video':
						return this._showVideoIframe(currentRemote);
						break;
					default:
						// url
						return this._loadRemoteContent(currentRemote);
						break;
				}
			}
		}, {
			key: '_isImage',
			value: function _isImage(string) {
				return string.match(/(^data:image\/.*,)|(\.(jp(e|g|eg)|gif|png|bmp|webp|svg)((\?|#).*)?$)/i);
			}
		}, {
			key: '_getYoutubeId',
			value: function _getYoutubeId(string) {
				var matches = string.match(/^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/);
				return matches && matches[2].length === 11 ? matches[2] : false;
			}
		}, {
			key: '_getVimeoId',
			value: function _getVimeoId(string) {
				return string.indexOf('vimeo') > 0 ? string : false;
			}
		}, {
			key: '_getInstagramId',
			value: function _getInstagramId(string) {
				return string.indexOf('instagram') > 0 ? string : false;
			}

			// layout private methods
		}, {
			key: '_calculateBorders',
			value: function _calculateBorders() {
				return {
					top: this._totalCssByAttribute('border-top-width'),
					right: this._totalCssByAttribute('border-right-width'),
					bottom: this._totalCssByAttribute('border-bottom-width'),
					left: this._totalCssByAttribute('border-left-width')
				};
			}
		}, {
			key: '_calculatePadding',
			value: function _calculatePadding() {
				return {
					top: this._totalCssByAttribute('padding-top'),
					right: this._totalCssByAttribute('padding-right'),
					bottom: this._totalCssByAttribute('padding-bottom'),
					left: this._totalCssByAttribute('padding-left')
				};
			}
		}, {
			key: '_totalCssByAttribute',
			value: function _totalCssByAttribute(attribute) {
				return parseFloat(this._$modalDialog.css(attribute)) + parseFloat(this._$modalContent.css(attribute)) + parseFloat(this._$modalBody.css(attribute));
			}
		}, {
			key: '_updateTitleAndFooter',
			value: function _updateTitleAndFooter() {
				var header = this._$modalContent.find('.modal-header');
				var footer = this._$modalContent.find('.modal-footer');
				var title = this._$element.data('title') || "";
				var caption = this._$element.data('footer') || "";

				if (title || this._config.always_show_close) header.css('display', '').find('.modal-title').html(title || "&nbsp;");else header.css('display', 'none');

				if (caption) footer.css('display', '').html(caption);else footer.css('display', 'none');

				return this;
			}
		}, {
			key: '_showLoading',
			value: function _showLoading() {
				this._$lightboxBody.html('<div class="modal-loading">' + this._config.loadingMessage + '</div>');
				return this;
			}
		}, {
			key: '_showYoutubeVideo',
			value: function _showYoutubeVideo(remote) {
				var id = this._getYoutubeId(remote);
				var query = remote.indexOf('&') > 0 ? remote.substr(remote.indexOf('&')) : '';
				var width = this._checkDimensions(this._$element.data('width') || 560);
				return this._showVideoIframe('//www.youtube.com/embed/' + id + '?badge=0&autoplay=1&html5=1' + query, width, width / (560 / 315));
			}
		}, {
			key: '_showVimeoVideo',
			value: function _showVimeoVideo(id) {
				var width = this._checkDimensions(this._$element.data('width') || 560);
				var height = width / (500 / 281); // aspect ratio
				return this._showVideoIframe(id + '?autoplay=1', width, height);
			}
		}, {
			key: '_showInstagramVideo',
			value: function _showInstagramVideo(id) {
				// instagram load their content into iframe's so this can be put straight into the element
				var width = this._checkDimensions(this._$element.data('width') || 612);
				this.resize(width);
				var height = width + 80;
				id = id.substr(-1) !== '/' ? id + '/' : id; // ensure id has trailing slash
				this._$lightboxBody.html('<iframe width="' + width + '" height="' + height + '" src="' + id + 'embed/" frameborder="0" allowfullscreen></iframe>');
				this._config.onContentLoaded.call(this);
				if (this._$modalArrows) //hide the arrows when showing video
					return this._$modalArrows.css('display', 'none');
			}
		}, {
			key: '_showVideoIframe',
			value: function _showVideoIframe(url, width, height) {
				// should be used for videos only. for remote content use loadRemoteContent (data-type=url)
				height = height || width; // default to square
				this.resize(width);
				this._$lightboxBody.html('<div class="embed-responsive embed-responsive-16by9"><iframe width="' + width + '" height="' + height + '" src="' + url + '" frameborder="0" allowfullscreen class="embed-responsive-item"></iframe></div>');
				this._config.onContentLoaded.call(this);
				if (this._$modalArrows) {
					this._$modalArrows.css('display', 'none');
				} //hide the arrows when showing video
				return this;
			}
		}, {
			key: '_loadRemoteContent',
			value: function _loadRemoteContent(url) {
				var _this3 = this;

				var width = this._$element.data('width') || 560;
				this.resize(width);

				var disableExternalCheck = this._$element.data('disableExternalCheck') || false;

				// external urls are loading into an iframe
				if (!disableExternalCheck && !this._isExternal(url)) {
					this._$lightboxBody.load(url, $.proxy(function () {
						return _this3._$element.trigger('loaded.bs.modal');
					}));
				} else {
					this._$lightboxBody.html('<iframe width="' + width + '" height="' + width + '" src="' + url + '" frameborder="0" allowfullscreen></iframe>');
					this._config.onContentLoaded.call(this);
				}

				if (this._$modalArrows) //hide the arrows when remote content
					this._$modalArrows.css('display', 'none');
				return this;
			}
		}, {
			key: '_isExternal',
			value: function _isExternal(url) {
				var match = url.match(/^([^:\/?#]+:)?(?:\/\/([^\/?#]*))?([^?#]+)?(\?[^#]*)?(#.*)?/);
				if (typeof match[1] === "string" && match[1].length > 0 && match[1].toLowerCase() !== location.protocol) return true;

				if (typeof match[2] === "string" && match[2].length > 0 && match[2].replace(new RegExp(':(' + ({
					"http:": 80,
					"https:": 443
				})[location.protocol] + ')?$'), "") !== location.host) return true;

				return false;
			}
		}, {
			key: '_error',
			value: function _error(message) {
				this._$lightboxBody.html(message);
				return this;
			}
		}, {
			key: '_preloadImage',
			value: function _preloadImage(src, onLoadShowImage) {
				var _this4 = this;

				var img = new Image();
				if (onLoadShowImage == null || onLoadShowImage === true) {
					img.onload = function () {
						var image = $('<img />');
						image.attr('src', img.src);
						image.addClass('img-fluid');
						_this4._$lightboxBody.html(image);
						if (_this4._$modalArrows) {
							_this4._$modalArrows.css('display', 'block');
						}
						if (_this4._config.scale_height) {
							_this4._scaleHeight(img.height, img.width);
						} else {
							_this4.resize(img.width);
						}
						return _this4._config.onContentLoaded.call(_this4);
					};
					img.onerror = function () {
						return _this4._error('Failed to load image: ' + src);
					};
				}

				img.src = src;
				return img;
			}
		}, {
			key: '_scaleHeight',
			value: function _scaleHeight(height, width) {

				//console.log(this, this._$modal, this._$modal.data('bs.modal'))
				//this._$modal.data('bs.modal')._handleUpdate()
				//scales the dialog based on height and width, takes all padding, borders, margins into account
				//only used if options.scale_height is true
				var headerHeight = this._$modalHeader.outerHeight(true) || 0;
				var footerHeight = this._$modalFooter.outerHeight(true) || 0;

				if (!this._$modalFooter.is(':visible')) footerHeight = 0;

				if (!this._$modalHeader.is(':visible')) headerHeight = 0;

				var border_padding = this._border.top + this._border.bottom + this._padding.top + this._padding.bottom;
				//calculated each time as resizing the window can cause them to change due to Bootstraps fluid margins
				var margins = parseFloat(this._$modalDialog.css('margin-top')) + parseFloat(this._$modalDialog.css('margin-bottom'));

				var max_height = $(window).height() - border_padding - margins - headerHeight - footerHeight;
				var factor = Math.min(max_height / height, 1);

				this._$modalDialog.css('height', 'auto').css('maxHeight', max_height);
				return this.resize(factor * width);
			}
		}, {
			key: '_checkDimensions',
			value: function _checkDimensions(width) {
				//check that the width given can be displayed, if not return the maximum size that can be
				var width_total = width + this._border.left + this._padding.left + this._padding.right + this._border.right;
				return width_total > document.body.clientWidth ? this._$modalBody.width() : width;
			}
		}], [{
			key: '_jQueryInterface',
			value: function _jQueryInterface(config, relatedTarget) {
				var _this5 = this;

				return this.each(function () {
					var $this = $(_this5);
					var _config = $.extend({}, Lightbox.Default, $this.data(), typeof config === 'object' && config);

					new Lightbox(_this5, _config);
				});
			}
		}]);

		return Lightbox;
	})();

	$.fn[NAME] = Lightbox._jQueryInterface;
	$.fn[NAME].Constructor = Lightbox;
	$.fn[NAME].noConflict = function () {
		$.fn[NAME] = JQUERY_NO_CONFLICT;
		return Lightbox._jQueryInterface;
	};

	return Lightbox;
})(jQuery);
//# sourceMappingURL=ekko-lightbox.js.map

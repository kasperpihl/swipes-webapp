define ["underscore"], (_) ->
	Backbone.View.extend
		presentModal: (options, callback) ->
			self = @
			@callback = callback
			@shown = true
			swipy.modalVC.presentView(@el, options, ->
				self.shown = false
				self.didCloseModal()
			)
			self.didPresentModal?()
		alignModal: ->
			swipy.modalVC.alignContent()
		dismissModal: ->
			swipy.modalVC.hideContent() if @shown
			@shown = false
		didCloseModal: ->
			@callback?(false)
			# override in subclass and remember to call @callback if needed
define [], () ->
	Backbone.View.extend
		presentModal: (options) ->
			self = @
			swipy.modalVC.presentView(@el, options, ->
				self.didCloseModal()
			)
		didCloseModal: ->
			# override in subclass for handling
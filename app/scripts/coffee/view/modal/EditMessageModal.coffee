define ["underscore",
		"js/view/modal/ModalView"
		"text!templates/modal/edit-message-modal.html"], (_, ModalView, Template) ->
	ModalView.extend
		className: 'edit-message-modal'
		initialize: (options) ->
			that = @
			@options = options
			@setTemplates()
			@render()

			# That hack is used because we have to wait for the previous modal to close (the action list modal)
			# setTimeout 0 is used to wait for one render cycle. Just what we need here.
			setTimeout () ->
				that.presentModal()
				that.afterOpen()
			, 0
		events:
			"click button.submit": "submit"
			"click button.cancel": "cancel"
			"keyup .full-modal": "keyup"
		setTemplates: ->
			@template = _.template Template, variable: "data"
		afterOpen: ->
			$('.modal-clickable-background').addClass('dark-opaque')
			@$el.find('textarea').val(@options.textAreaValue)
			@$el.find('textarea').focus()
		afterClose: ->
			$('.modal-clickable-background').removeClass('dark-opaque')
			@dismissModal()
		render: ->
			html = @template()
			@$el.html html
			return @
		submit: (e) ->
			@options.submitCallback(@$el.find('textarea').val())
			@afterClose()
		cancel: (e) ->
			@afterClose()
		keyup: (e) ->
			if e.keyCode == 13 && e.target.type != 'textarea'
				@submit()
			if e.keyCode == 27
				@cancel()
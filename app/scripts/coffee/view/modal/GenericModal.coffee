define ["underscore"
		"js/view/modal/ModalView"
		"text!templates/modal/input-modal.html"
		"text!templates/modal/delete-modal.html"
		"text!templates/modal/textarea-modal.html"
		"text!templates/modal/import-asana-modal.html"],
	(_, ModalView, InputModal, DeleteModal, TextareaModal, ImportAsanaModal) ->
		ModalView.extend
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
				@template = _.template @typeToTemplate(@options.type), variable: "data"
			afterOpen: ->
				self = @
				$('.modal-clickable-background').addClass('dark-opaque')

				if @options.inputSelector
					input = $(@options.inputSelector)
					value = input.val()
					
					#this doesn't actually work, but it fixes the issue with modals not pulling the text for edit or create task, no idea why
					chatVal = self.closest('.chat-message').children('.chat-right-side-container').children('.message-container').text()
					console.log(chatVal)

					input.focus()
					input.on 'keyup', () ->
						self.$el.find("p.error").removeClass('active')
					# Move the cursor to the end
					input.val('').val(value)
				else
					@$el.find(".full-modal").focus()
			close: ->
				$('.modal-clickable-background').removeClass('dark-opaque')
				@dismissModal()
			render: ->
				html = @template @options.tmplOptions
				@$el.html html
				return @
			submit: (e) ->
				if @options.inputSelector
					errors = @options.submitCallback(@$el.find(@options.inputSelector).val())
				else
					errors = @options.submitCallback()

				if errors? and errors.length > 0
					@$el.find("p.error").text(errors[0].error).addClass('active')
				else
					@close()
			cancel: (e) ->
				@close()
			keyup: (e) ->
				if e.keyCode == 13 && e.target.type != 'textarea'
					@submit()
				if e.keyCode == 27
					@cancel()
			typeToTemplate: (type) ->
				map =
					'textareaModal': TextareaModal
					'inputModal': InputModal
					'deleteModal': DeleteModal
					'importAsanaModal': ImportAsanaModal

				return map[type]

define ["underscore",
		"js/view/modal/ModalView"
		"text!templates/modal/welcome-modal.html"], (_, ModalView, Tmpl) ->
	ModalView.extend
		className: 'welcome-modal'
		initialize: ->
			@setTemplate()
		events:
			"click .start-button" : "clickedStart"
		setTemplate: ->
			@template = _.template Tmpl, {variable: "data"}
		render: ->
			@$el.html @template()
			return @
		clickedStart: (e) ->
			@dismissModal()
define ["underscore",
		"text!templates/modal/list-action-modal.html", 
		], (_, ListActionModalTpl) ->
	Backbone.View.extend
		tagName: 'ul'
		className: "list-action-modal"
		events:
			"click .list-action" : "clickedAction"
		initialize: ->
			@template = _.template ListActionModalTpl, {variable: "data"}
		loadActionsAndCallback: (actions, callback) ->
			@callback = callback if _.isFunction(callback) 
			@actions = []
			for act, i in actions
				action = {}
				action.name = act if _.isString(act)
				if _.isObject(act)
					action.icon = act.icon if act.icon?
					action.name = act.name if act.name?
					action.action = act.action if act.action?
				@actions.push(action)
		clickedAction: (e) ->
			action = $(e.currentTarget).attr("data-href")
			if action? and action
				@callback?(action)
		render: ->
			@$el.html @template({actions: @actions})

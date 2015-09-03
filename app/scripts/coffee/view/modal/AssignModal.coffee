define ["underscore",
		"js/view/modal/ModalView"
		"text!templates/modal/assign-modal.html"], (_, ModalView, Tmpl) ->
	ModalView.extend
		className: 'assign-modal'
		initialize: ->
			@setTemplate()
			throw new Error("AssignModal must have model on init") if !@model?
			@bouncedRender = _.debounce(@render, 5)
			_.bindAll(@, "clickedPerson", "render", "bouncedRender")
			@model.on("change:assignees", @bouncedRender )
		events:
			"click li.member" : "clickedPerson"
		setTemplate: ->
			@template = _.template Tmpl, {variable: "data"}
		render: ->
			throw new Error("AssignModal must have dataSource") if !@dataSource?
			throw new Error("AssignModal dataSource must implement assignModalPeopleToAssign") if !_.isFunction(@dataSource.assignModalPeopleToAssign)
			
			
			people = @dataSource.assignModalPeopleToAssign(@)
			html = @template({people: people})
			@$el.html html
			return @
		clickedPerson: (e) ->
			$el = $(e.currentTarget)
			memberId = $el.attr("data-href")
			targetUser = swipy.slackCollections.users.get(memberId)
			@model.assign( memberId, true )
			if @model.get("projectLocalId")
				capitalizedName = swipy.slackCollections.users.me().capitalizedName()
				if swipy.slackCollections.users.me().id isnt targetUser.id
					sofiMessage = capitalizedName + " assigned you the task \"" + @model.getTaskLinkForSlack() + "\"";
					swipy.slackSync.sendMessageAsSofi(sofiMessage, "@" + targetUser.get("name"))
			@dismissModal()
			return
			@assignPerson(memberId).then( =>
					
			)
		assignPerson: (href, callback) ->
			dfd = new $.Deferred()
			el = @$el.find('li[data-href='+href+']')
			el.addClass('animated-short')
			el.addClass('fadeOut')
			setTimeout(->
				dfd.resolve()
			, 300)
			return dfd.promise()
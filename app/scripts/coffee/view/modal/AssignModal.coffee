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
			@assignPerson(memberId).then( =>
				@model.assign( memberId, true )
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
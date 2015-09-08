define ["underscore",
		"js/view/modal/ModalView"
		"text!templates/modal/invite-modal.html"], (_, ModalView, Tmpl) ->
	ModalView.extend
		className: 'invite-modal'
		initialize: ->
			@type = "Standard Invite"
			@setTemplate()
			@bouncedRender = _.debounce(@render, 5)
			_.bindAll(@, "clickedPerson", "render", "bouncedRender")
		events:
			"click li.member" : "clickedPerson"
		setTemplate: ->
			@template = _.template Tmpl, {variable: "data"}
		render: ->
			throw new Error("AssignModal must have dataSource") if !@dataSource?
			throw new Error("AssignModal dataSource must implement inviteModalPeopleToInvite") if !_.isFunction(@dataSource.inviteModalPeopleToInvite)
			
			
			people = @dataSource.inviteModalPeopleToInvite(@)
			html = @template({people: people})
			@$el.html html
			return @
		clickedPerson: (e) ->
			$el = $(e.currentTarget)
			memberId = $el.attr("data-href")
			targetUser = swipy.slackCollections.users.get(memberId)
			swipy.api.callAPI("invite/slack", "POST", {invite: {"slackUserId": targetUser.id, "type": @type}}, (res, error) =>
				console.log "res from invite", res, error
				if res and res.ok
					swipy.analytics.logEvent("Invite Sent", {"Hours Since Signup": res.hoursSinceSignup})
			)
			@invitePerson(memberId)
		invitePerson: (href, callback) ->
			dfd = new $.Deferred()
			el = @$el.find('li[data-href='+href+']')
			el.addClass('animated-short')
			el.addClass('fadeOut')
			setTimeout(->
				el.remove()
				dfd.resolve()
			, 300)
			return dfd.promise()
		didCloseModal: ->
			if swipy.onboarding.getCurrentEvent() is "WaitingForInvites"
				swipy.onboarding.setCurrentEvent("DidInviteUsers",true) 
			@callback?(false)
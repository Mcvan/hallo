((jQuery) ->
    z = new VIE
    z.use new z.StanbolService
        proxyDisabled: true
        url : "http://dev.iks-project.eu:8081",

    jQuery.widget "IKS.halloannotate",
        options:
            vie: z
            editable: null
            toolbar: null

        _create: ->
            widget = this
            widget.buttons = {}

            buttonset = jQuery "<span class=\"#{widget.widgetName}\"></span>"
            buttonize = (cmd, label) =>
                id = "#{@options.uuid}-#{cmd}"
                buttonset.append jQuery("<input id=\"#{id}\" type=\"checkbox\" /><label for=\"#{id}\">#{label}</label>").button()
                button = jQuery "##{id}", buttonset
                button.attr "hallo-command", cmd
                button.bind "change", (event) ->
                    cmd = jQuery(this).attr "hallo-command"
                    do widget[cmd]
                widget.buttons[cmd] = button

            buttonize "enhance", "Enhance"
            buttonize "done", "Done"
            buttonize "acceptAll", "Accept all"
            buttonset.buttonset()
            widget.buttons.done.hide()
            widget.buttons.acceptAll.hide()
            @options.toolbar.append buttonset
            @instantiate()


        instantiate: ->
            @options.editable.element.annotate
                vie: @options.vie
                debug: true
                showTooltip: true
            # @buttons.acceptAll.hide()
        acceptAll: ->
            @options.editable.element.each ->
                jQuery(this).annotate "acceptAll", (report) ->
                    console.log "AcceptAll finished with the report:", report

            @buttons.acceptAll.button "disable"

        enhance: ->
            widget = @
            console.info ".content", @options.editable.element
            origLabel = @buttons.enhance.button( "option", "label" )
            @buttons.enhance
            .button("disable")
            .button "option", "label", "in progress..."
            try
                @options.editable.element.annotate "enable", (success) =>
                    if success
                        @buttons.enhance.button("disable").button "option", "label", origLabel
                        @buttons.enhance.button("enable").hide()
                        @buttons.enhance.hide()
                        @buttons.done.show()
                        @buttons.acceptAll.show()
                        console.log "done"
                    else
                        @buttons.enhance.show()
                        .button("enable")
                        .button "option", "label", "error, see the log.. Try to enhance again!"
            catch e
                alert e
        done: ->
            @options.editable.element.annotate "disable"
            @buttons.enhance.show().button "option", "label", "Enhance!"

            @buttons.done.button("hide")
            @buttons.acceptAll.buttonset("hide")
)(jQuery)

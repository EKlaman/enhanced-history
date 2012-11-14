class BH.Views.DayView extends Backbone.View
  @include BH.Modules.chromeSupport
  @include BH.Modules.searchSupport
  @include BH.Modules.topLevelSupport

  template: BH.Templates['day']

  className: 'day_view with_controls'

  events:
    'click .delete_day': 'onDeleteAllClicked'
    'click .back_to_week': 'onBackToWeekClicked'
    'keyup .search': 'onSearchTyped'
    'blur .search': 'onSearchBlurred'

  initialize: ->
    @history = @options.history
    @history.bind('change', @onDayHistoryLoaded, @)

  render: ->
    properties = _.extend @getI18nValues(), @model.toTemplate()
    html = Mustache.to_html(@template, properties)
    @$el.html html
    @

  onDayHistoryLoaded: ->
    @renderHistory()
    @updateDeleteButton()

  onDeleteAllClicked: (ev) ->
    @promptToDeleteAllVisits()

  onBackToWeekClicked: ->
    @$('.content').html('')

  pageTitle: ->
    @model.toTemplate().formalDate

  renderHistory: ->
    @dayResultsView = new BH.Views.DayResultsView
      model: @history
    @$('.content').html @dayResultsView.render().el

  updateDeleteButton: ->
    deleteButton = @$('button')
    if @history.isEmpty()
      deleteButton.attr('disabled', 'disabled')
    else
      deleteButton.removeAttr('disabled')

  updateUrl: ->
    router.navigate(BH.Lib.Url.week(@options.weekModel.id))

  promptToDeleteAllVisits: ->
    promptMessage = @t('confirm_delete_all_visits', [@model.toJSON().formalDate])
    @promptView = BH.Views.CreatePrompt(promptMessage)
    @promptView.open()
    @promptView.model.on('change', @promptAction, @)

  promptAction: (prompt) ->
    if prompt.get('action')
      @history.destroy()
      @history.fetch
        success: =>
          @promptView.close()
    else
      @promptView.close()

  getI18nValues: ->
    properties = @t [
      'collapse_button',
      'expand_button',
      'delete_all_visits_for_filter_button',
      'no_visits_found',
      'search_input_placeholder_text',
    ]
    properties['i18n_back_to_week_link'] = @t('back_to_week_link', [
      @t('back_arrow')
    ])
    properties
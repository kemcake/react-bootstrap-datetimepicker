###* @jsx React.DOM ###

React = require 'react'
DateTimePicker = require './DateTimePicker'
moment = require 'moment'
Glyphicon = require 'react-bootstrap/Glyphicon'

DateTimeField = React.createClass(

  propTypes:
    dateTime: React.PropTypes.string
    onChange: React.PropTypes.func
    format: React.PropTypes.string
    inputFormat: React.PropTypes.string

  getDefaultProps: ->
    dateTime: moment()
    format: 'X'
    inputFormat: "MM/DD/YY H:mm A"
    showToday: true
    daysOfWeekDisabled: []

  getInitialState: ->
    showDatePicker: true
    showTimePicker: false
    widgetStyle:
      display: 'block'
      position: 'absolute'
      left: -9999
      zIndex: '9999 !important'
    viewDate: moment(@props.dateTime, @props.format).startOf("month")
    selectedDate: moment(@props.dateTime, @props.format)
    inputValue: moment(@props.dateTime, @props.format).format(@props.inputFormat)

  componentWillReceiveProps: (nextProps) ->
    @setState
      viewDate: moment(nextProps.dateTime, nextProps.format).startOf("month")
      selectedDate: moment(nextProps.dateTime, nextProps.format)
      inputValue: moment(nextProps.dateTime, nextProps.format).format(nextProps.inputFormat)

  # to improve with detection only onBlur
  onChange: (event) ->
    if moment(event.target.value, @props.format).isValid()
      @setState
        selectedDate: moment(event.target.value, @props.format)
        inputValue: moment(event.target.value, @props.format).format(@props.inputFormat)
    else
      @setState inputValue: event.target.value
      console.log "This is not a valid date"

    @props.onChange(@state.selectedDate.format(@props.format))

  setSelectedDate: (e) ->
    @setState selectedDate: @state.viewDate.clone().date(parseInt(e.target.innerHTML)).hour(@state.selectedDate.hours()).minute(@state.selectedDate.minutes()), ->
      @closePicker()
      @props.onChange(@state.selectedDate.format(@props.format))
      @setState inputValue: @state.selectedDate.format(@props.inputFormat)

  setSelectedHour: (e) ->
    @setState selectedDate: @state.selectedDate.clone().hour(parseInt(e.target.innerHTML)).minute(@state.selectedDate.minutes()), ->
      @closePicker()
      @props.onChange(@state.selectedDate.format(@props.format))
      @setState inputValue: @state.selectedDate.format(@props.inputFormat)

  setSelectedMinute: (e) ->
    @setState selectedDate: @state.selectedDate.clone().hour(@state.selectedDate.hours()).minute(parseInt(e.target.innerHTML)), ->
      @closePicker()
      @props.onChange(@state.selectedDate.format(@props.format))
      @setState inputValue: @state.selectedDate.format(@props.inputFormat)

  setViewMonth: (month) ->
    @setState viewDate: @state.viewDate.clone().month(month)

  setViewYear: (year) ->
    @setState viewDate: @state.viewDate.clone().year(year)

  addMinute: ->
    @setState selectedDate: @state.selectedDate.clone().add(1, "minutes"), ->
      @props.onChange(@state.selectedDate.format(@props.format))

  addHour: ->
    @setState selectedDate: @state.selectedDate.clone().add(1, "hours"), ->
      @props.onChange(@state.selectedDate.format(@props.format))

  addMonth: ->
    @setState viewDate: @state.viewDate.add(1, "months")

  addYear: ->
    @setState viewDate: @state.viewDate.add(1, "years")

  addDecade: ->
    @setState viewDate: @state.viewDate.add(10, "years")

  subtractMinute: ->
    @setState selectedDate: @state.selectedDate.clone().subtract(1, "minutes"), ->
      @props.onChange(@state.selectedDate.format(@props.format))

  subtractHour: ->
    @setState selectedDate: @state.selectedDate.clone().subtract(1, "hours"), ->
      @props.onChange(@state.selectedDate.format(@props.format))

  subtractMonth: ->
    @setState viewDate: @state.viewDate.subtract(1, "months")

  subtractYear: ->
    @setState viewDate: @state.viewDate.subtract(1, "years")

  subtractDecade: ->
    @setState viewDate: @state.viewDate.subtract(10, "years")

  togglePeriod: ->
    if @state.selectedDate.hour() > 12
      @setState selectedDate: @state.selectedDate.clone().subtract(12, 'hours')
    else
      @setState selectedDate: @state.selectedDate.clone().add(12, 'hours')

  togglePicker: ->
    @setState
      showDatePicker: !@state.showDatePicker
      showTimePicker: !@state.showTimePicker

  onClick: ->
    if @state.showPicker
      @closePicker()
    else
      @setState showPicker: true

      gBCR = @refs.dtpbutton.getDOMNode().getBoundingClientRect()
      classes =
        "bootstrap-datetimepicker-widget": true
        "dropdown-menu": true

      offset =
        top: gBCR.top + window.pageYOffset - document.documentElement.clientTop
        left: gBCR.left + window.pageXOffset - document.documentElement.clientLeft

      offset.top = offset.top + @refs.datetimepicker.getDOMNode().offsetHeight

      scrollTop = `(window.pageYOffset !== undefined) ? window.pageYOffset : (document.documentElement || document.body.parentNode || document.body).scrollTop`


      placePosition =
        if @props.direction == 'up'
          'top'
        else if @props.direction == 'bottom'
          'bottom'
        else if @props.direction == 'auto'
          if offset.top + @refs.widget.getDOMNode().offsetHeight > window.offsetHeight + scrollTop && @refs.widget.offsetHeight + @refs.datetimepicker.getDOMNode().offsetHeight > offset.top
            'top'
          else
            'bottom'

      if placePosition == 'top'
        # offset.top -= @refs.widget.getDOMNode().offsetHeight + @refs.datetimepicker.getDOMNode().offsetHeight + 15
        offset.top = - @refs.widget.getDOMNode().offsetHeight-this.getDOMNode().clientHeight-2
        classes["top"] = true
        classes["bottom"] = false
        classes['pull-right'] = true
      else
        # offset.top += 1
        offset.top = 40
        classes["top"] = false
        classes["bottom"] = true
        classes['pull-right'] = true


      # if @props.orientation == 'left'
      #   classes["left-oriented"] = true
      #   offset.left = offset.left - @refs.widget.getDOMNode.

      # if document.body.clientWidth < offset.left + @refs.widget.getDOMNode().offsetWidth
      #   offset.right = document.body.clientWidth - offset.left - @refs.dtpbutton.getDOMNode().offsetWidth
      #   offset.left = "auto"
      #   classes['pull-right'] = true
      # else
      #   offset.right = "auto"
      #   classes["pull-right"] = false

      styles =
        display: 'block'
        position: 'absolute'
        top: offset.top
        # top: 40
        # left: offset.left
        # right: offset.right
        left: 'auto'
        right: 40

      @setState
        widgetStyle: styles
        widgetClasses: classes

  closePicker: (e) ->
    style = @state.widgetStyle
    style['left'] = -9999

    @setState
      showPicker: false
      widgetStyle: style



  renderOverlay: ->
    styles =
      position: 'fixed'
      top: 0
      bottom: 0
      left: 0
      right: 0
      zIndex: '999'

    if @state.showPicker
      `(<div style={styles} onClick={this.closePicker} />)`
    else
      `<span />`

  render: ->

    `(
          <div>
            {this.renderOverlay()}
            <DateTimePicker ref="widget"
                  widgetClasses={this.state.widgetClasses}
                  widgetStyle={this.state.widgetStyle}
                  showDatePicker={this.state.showDatePicker}
                  showTimePicker={this.state.showTimePicker}
                  viewDate={this.state.viewDate}
                  selectedDate={this.state.selectedDate}
                  showToday={this.props.showToday}
                  daysOfWeekDisabled={this.props.daysOfWeekDisabled}
                  addDecade={this.addDecade}
                  addYear={this.addYear}
                  addMonth={this.addMonth}
                  addHour={this.addHour}
                  addMinute={this.addMinute}
                  subtractDecade={this.subtractDecade}
                  subtractYear={this.subtractYear}
                  subtractMonth={this.subtractMonth}
                  subtractHour={this.subtractHour}
                  subtractMinute={this.subtractMinute}
                  setViewYear={this.setViewYear}
                  setViewMonth={this.setViewMonth}
                  setSelectedDate={this.setSelectedDate}
                  setSelectedHour={this.setSelectedHour}
                  setSelectedMinute={this.setSelectedMinute}
                  togglePicker={this.togglePicker}
                  togglePeriod={this.togglePeriod}
            />
            <div className="input-group date" ref="datetimepicker">
              <input type="text" className="form-control" onChange={this.onChange} value={this.state.selectedDate.format(this.props.inputFormat)} />
              <span className="input-group-addon" onClick={this.onClick} onBlur={this.onBlur} ref="dtpbutton"><Glyphicon glyph="calendar" /></span>
            </div>
          </div>
    )`
)

module.exports = DateTimeField

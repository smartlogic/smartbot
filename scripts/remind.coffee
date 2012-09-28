# Description:
#   Forgetful? Add reminders
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot remind <me|user> in <time> to <action> - Set a reminder in <time> to do an <action> <time> is in the format 1 day, 2 hours, 5 minutes etc. Time segments are optional, as are commas
#
# Authors:
#   whitman

class Reminders
  constructor: (@robot) ->
    @cache = []
    @current_timeout = null

    @robot.brain.on 'loaded', =>
      if @robot.brain.data.reminders
        @cache = @robot.brain.data.reminders
        @queue()

  add: (reminder) ->
    @cache.push reminder
    @cache.sort (a, b) -> a.due - b.due
    @robot.brain.data.reminders = @cache
    @queue()

  removeFirst: ->
    reminder = @cache.shift()
    @robot.brain.data.reminders = @cache
    return reminder

  queue: ->
    clearTimeout @current_timeout if @current_timeout
    if @cache.length > 0
      now = new Date().getTime()
      @removeFirst() until @cache.length is 0 or @cache[0].due > now
      if @cache.length > 0
        trigger = =>
          reminder = @removeFirst()
          @robot.send reminder.for, reminder.forName() + ', ' + reminder.fromName() + ' asked me to remind you to ' + reminder.action
          @queue()
        @current_timeout = setTimeout trigger, @cache[0].due - now

class Reminder
  constructor: (@for, @from, @time, @action) ->
    @time.replace(/^\s+|\s+$/g, '')

    periods =
      weeks:
        value: 0
        regex: "weeks?"
      days:
        value: 0
        regex: "days?"
      hours:
        value: 0
        regex: "hours?|hrs?"
      minutes:
        value: 0
        regex: "minutes?|mins?"
      seconds:
        value: 0
        regex: "seconds?|secs?"

    for period of periods
      pattern = new RegExp('^.*?([\\d\\.]+)\\s*(?:(?:' + periods[period].regex + ')).*$', 'i')
      matches = pattern.exec(@time)
      periods[period].value = parseInt(matches[1]) if matches

    @due = new Date().getTime()
    @due += ((periods.weeks.value * 604800) + (periods.days.value * 86400) + (periods.hours.value * 3600) + (periods.minutes.value * 60) + periods.seconds.value) * 1000

  dueDate: ->
    dueDate = new Date @due
    dueDate.toLocaleString()

  fromName: ->
    if @for == @from
      'you'
    else
      @from.name

  toName: ->
    if @for == @from
      'you'
    else
      @for.name

module.exports = (robot) ->

  # Find the user by user name from hubot's brain.
  #
  # name - A full or partial name match.
  #
  # Returns a user object if a single user is found, an array of users if more
  # than one user matched the name or false if no user is found.
  findUser = (name) ->
    users = robot.usersForFuzzyName name
    if users.length is 1
      users[0]
    else if users.length > 1
      users
    else
      false

  robot.respond /whois ([\S]+ ?[\S]*)/i, (msg) ->
    user = findUser msg.match[1]
    msg.send msg.match[1] + ' is ' + user

  reminders = new Reminders robot

  robot.respond /remind ([\S]+ ?[\S]*) in ((?:(?:\d+) (?:weeks?|days?|hours?|hrs?|minutes?|mins?|seconds?|secs?)[ ,]*(?:and)? +)+)to (.*)/i, (msg) ->
    user = switch msg.match[1]
      when "me" then findUser msg.message.user
      else findUser msg.match[1]
    time = msg.match[2]
    action = msg.match[3]
    from = msg.message.user
    reminder = new Reminder user, from, time, action
    reminders.add reminder
    msg.send 'I\'ll remind ' + reminder.toName() + ' to ' + action + ' on ' + reminder.dueDate()

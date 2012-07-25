# Description:
#   Track how does that work
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   <thing>!! - give thing some how does that work
#   hubot hdtw <thing> - check thing's wtf'ery (if <thing> is omitted, show the top 5)
#   hubot hdtw empty <thing> - empty a thing's wtf'ery
#   hubot hdtw list - show the top 5
#
# Author:
#   stuartf
#   oestrich

class HowDoesThatWork

  constructor: (@robot) ->
    @cache = {}

    @increment_responses = [
      "uh oh", "I'm amazed as well"
    ]

    @robot.brain.on 'loaded', =>
      if @robot.brain.data.hdtw
        @cache = @robot.brain.data.hdtw

  kill: (thing) ->
    delete @cache[thing]
    @robot.brain.data.hdtw = @cache

  increment: (thing) ->
    @cache[thing] ?= 0
    @cache[thing] += 1
    @robot.brain.data.hdtw = @cache

  incrementResponse: ->
     @increment_responses[Math.floor(Math.random() * @increment_responses.length)]

  get: (thing) ->
    k = if @cache[thing] then @cache[thing] else 0
    return k

  sort: ->
    s = []
    for key, val of @cache
      s.push({ name: key, hdtw: val })
    s.sort (a, b) -> b.hdtw - a.hdtw

  top: (n = 5) ->
    sorted = @sort()
    sorted.slice(0, n)

module.exports = (robot) ->
  hdtw = new HowDoesThatWork robot
  robot.hear /(\S+[^+\s])!!(\s|$)/, (msg) ->
    subject = msg.match[1].toLowerCase()
    hdtw.increment subject
    msg.send "#{subject} #{hdtw.incrementResponse()} (How does that work count: #{hdtw.get(subject)})"

  robot.respond /hdtw empty ?(\S+[^-\s])$/i, (msg) ->
    subject = msg.match[1].toLowerCase()
    hdtw.kill subject
    msg.send "#{subject} has had its how does that work count scattered to the winds."

  robot.respond /hdtw( best)?$/i, (msg) ->
    verbiage = ["The Worst"]
    for item, rank in hdtw.top()
      verbiage.push "#{rank + 1}. #{item.name} - #{item.hdtw}"
    msg.send verbiage.join("\n")

  robot.respond /hdtw (\S+[^-\s])$/i, (msg) ->
    match = msg.match[1].toLowerCase()
    if match != "best" && match != "worst"
      msg.send "\"#{match}\" has #{hdtw.get(match)} wtf'ery."


# A way to define what sam says

module.exports = (robot) ->
  robot.hear /./i, (msg) -> 
    if msg.message.user.name == "Eric Oestrich"
      msg.send "I see you Eric"

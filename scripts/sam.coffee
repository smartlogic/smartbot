# A way to define what sam says

module.exports = (robot) ->
  robot.hear /./i, (msg) -> 
    if msg.message.user.name == "Sam Goldman"
      words = msg.message.text.split(" ")

      longest = ""
      longestSize = 0

      for word in words
        do (word) ->
          if word.length > longestSize
            longestSize = word.length
            longest = word

      msg.send "Hubot: define me " +longest

net = require("net")


# Small, fake SMTP server to fake interaction with CozyMail.
class exports.SMTPFake
  
  constructor: (@port) ->
    index = 0
    
    responses = [
      "220 localhost ESMTP Exim\r\n"
      "250 Hello mydomain.com\r\n"
      "250 Ok\r\n"
      "250 Accepted\r\n"
      "250 Ok\r\n"
      "250 Ok\r\n"
      "354 Enter message, ending with “.” on a line by itself\r\n"
      "250 OK\r\n"
    ]

    net.createServer((socket) ->
      
      send = ->
        console.log "SMTPFake >> " + responses[index % responses.length]
        socket.write responses[index % responses.length]
        index++
  
      socket.name = socket.remoteAddress + ":" + socket.remotePort
  
      send()
      
      socket.write responses[index % responses.length]
      index++
  
      socket.on "data", (data) ->
        console.log "SMTPFake << " + data
        send()

      socket.on "end", ->
        console.log "Client disconnected"

    ).listen @port

    console.log "Fake SMTP server running at port " + @port
net = require("net")


# Small, fake IMAP server to fake interaction with CozyMail.
class exports.IMAPFake
  
  constructor: (@port) ->
    index = 0
    
    responses = [
      ["* OK [CAPABILITY IMAP4REV1 LITERAL+ SASL-IR LOGIN-REFERRALS AUTH=LOGIN] localhost \r\n"]
      [
        "* CAPABILITY IMAP4REV1 AUTH=LOGIN \r\n"
        "A1 OK CAPABILITY completed \r\n"
      ]
      ["A2 OK User logged in \r\n"]
      [
        "* CAPABILITY IMAP4REV1 AUTH=LOGIN \r\n"
        "A3 OK CAPABILITY completed \r\n"
      ]
      [
        '* LIST (\NoSelect) "/" Mail/inbox \r\n'
        "A4 OK LIST completed \r\n"
      ]
      [
        "* FLAGS (\Answered \Flagged \Draft \Deleted \Seen) \r\n"
        "* OK [PERMANENTFLAGS (\Answered \Flagged \Draft \Deleted \Seen \*)] \r\n"
        "* 12345 EXISTS \r\n"
        "* 1 RECENT \r\n"
        "* OK [UIDVALIDITY 1062186210] \r\n"
        "* OK [UIDNEXT 12346] \r\n"
        "A5 OK [READ-WRITE] Completed \r\n"
      ]
      [
        "* SEARCH 1\r\n"
        "A6 OK UID SEARCH Completed \r\n"
      ]
      [
        "* 1 FETCH (X-GM-THRID 12345 X-GM-MSGID 12345 X-GM-LABELS (\"\\Important\" \"\\Sent\") UID 1 INTERNALDATE \"28-Aug-2012 20:40:04 +0000\" FLAGS () BODYSTRUCTURE ((\"TEXT\" \"PLAIN\" (\"CHARSET\" \"utf-8\") NIL NIL \"QUOTED-PRINTABLE\" 4 0 NIL NIL NIL)(\"TEXT\" \"HTML\" (\"CHARSET\" \"utf-8\") NIL NIL \"QUOTED-PRINTABLE\" 4 0 NIL NIL NIL) \"ALTERNATIVE\" (\"BOUNDARY\" \"----mailcomposer-?=_1-1346186404309\") NIL NIL) BODY[] {782}\r\n
Return-Path: <test@mycozycloud.com>\r\n
Received: from localhost\r\n
        Tue, 28 Aug 2012 01:02:03 -0700 (PDT)\r\n
MIME-Version: 1.0\r\n
X-Mailer: Nodemailer (0.3.22; +http://andris9.github.com/Nodemailer/)\r\n
Date: Tue, 28 Aug 2012 01:02:03 -0700 (PDT)\r\n
>>>>>>> 6b30f329a7da3bdab0556d42423b156ca80ec552
Message-Id: <1346186402417.5af634ff@Nodemailer>\r\n
From: test@mycozycloud.com\r\n
To: support@mycozycloud.com\r\n
Subject: Subject\r\n
Content-Type: multipart/alternative;\r\n
        boundary=\"----mailcomposer-?=_1-1346186404309\"\r\n
\r\n
------mailcomposer-?=_1-1346186404309\r\n
Content-Type: text/plain; charset=utf-8\r\n
Content-Transfer-Encoding: quoted-printable\r\n
\r\n
html body\r\n
------mailcomposer-?=_1-1346186404309\r\n
Content-Type: text/html; charset=utf-8\r\n
Content-Transfer-Encoding: quoted-printable\r\n
\r\n
plain text\r\n
------mailcomposer-?=_1-1346186404309--\r\n
)\r\n",
        "A7 OK Success\r\n"
      ]
      [
        "* BYE LOGOUT Requested \r\n"
        "A8 OK Complete\r\n"
      ]
    ]

    net.createServer((socket) ->
      
      send = ->
        for message in responses[index % responses.length]
          console.log "IMAPFake >> " + message
          socket.write message
        index++
        if index >= responses.length
          socket.end()
  
      socket.name = socket.remoteAddress + ":" + socket.remotePort
  
      send()
  
      socket.on "data", (data) ->
        console.log "IMAPFake << " + data
        send()

      socket.on "end", ->
        console.log "Client disconnected"
        
      socket.on "error", (error) ->
        console.error error.toString()

    ).listen @port

    console.log "Fake IMAP server running at port " + @port

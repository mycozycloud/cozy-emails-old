americano = require 'americano-cozy'

mailboxRequest = -> emit doc.mailbox, doc
dateIdRequest = -> emit [doc.dateValueOf, doc._id], doc
dateRequest = -> emit doc.dateValueOf, doc
dateMailboxRequest = -> emit [doc.mailbox, doc.dateValueOf], doc
folderDateRequest = -> emit [doc.folder, doc.dateValueOf], doc

byEmailRequest = -> emit doc.login, doc

byMailboxRequest = -> emit doc.mailbox, doc
byTypeRequest = -> emit doc.specialType, doc

module.exports =

    mail:
        all: americano.defaultRequests.all
        date: dateRequest
        dateId: dateIdRequest
        byMailbox: mailboxRequest
        dateByMailbox: dateMailboxRequest
        folderDate: folderDate

    mailbox:
        all: americano.defaultRequests.all
        byEmail: byEmailRequest

    mailfolder:
        all: americano.defaultRequests.all
        byMailbox: byMailboxRequest
        byType: byTypeRequest

# Cozy Mail

One of the first applications available on the platform - email client and aggregator.


# How the idea was born ?

Most of us have to cope with a handful of mailboxes every day - personal, professional, legacy one. Sometimes your boss forces you to use their solution, he paid so much for, so you click and open, and click..

Moreover, at some point you realize you don't won your data anymore - it is all hosted somewhere, by a huge, nameless company.


You'd like to have all your data in one place, choose this place, and become free ? And perhaps you'd also like this software to be reliable, well-supported, and ... open source ?

You're right, grab your copy of CozyMail. It's free !



# So, what does it do ?

Cozy Mail will let You configure all your mailboxes via smtp+imap, synchronize the content (mail you marked as read will be visible in cozy as well as in your legacy mailbox, just in case), and use all of them as one via a cozy web interface.

Yes, we paid much attention to make the interface easy to use, nice and lean.


# Well, great! So how it works ?

Our stack includes node.js, mongodb, expressjs, railwayjs, backbone, stylus, jade and brunch to start with.

A bunch of top technologies, becoming extremely popular due to their innovative nature... Well, nice things.



# Okay, so where are we in the development ?

For today, application makes it possible to configure mailboxes, import all your mail and send mail.

Once you have your data, it will be nicely displayed (filtered by mailboxes) in our quicky interface.

Because the datasystem of Cozy isn't ready yet, you can't manage attachments though (yes, we're working at it hard !).





# So, I can try it ?!

Sure, it's free and easy. The code is open source and you can even propose an improvement.

You can simply install it on your Cozy Cloud installation by clicking on the
"add a new application" button and copy/pasting this git url in the displayed
form: https://github.com/mycozycloud/cozy-mails.git 

If you want to test it locally, what You need to do is:

* install node.js, 
* install and run mongodb and redis,
* clone this repository,
* install dependencies: npm install
* you may like to install coffee globally: npm install -g coffee
* run the server: coffee server.coffee
* open your browser at localhost:8003 and enjoy!



# TODO/Issues

There are few things to implement yet:
* attachments - because Cozy doesn't have it's solution to store files yet, CozyMails is waiting for that to store Your attachments,
* displaying the attached images is mails - look above,




# Authors

At the moment the application is being developed by Mikolaj Pawlikowski (mikolaj.pawlikowski.pl)


# About Cozy

Cozy Mails is suited to be deployed on the Cozy platform. Cozy is the personal
server for everyone. It allows you to install your every day web applications 
easily on your server, a single place you control. This means you can manage 
efficiently your data while protecting your privacy.

More informations and hosting services on:
http://www.mycozycloud.com

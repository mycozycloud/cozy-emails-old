(function(/*! Brunch !*/) {
  'use strict';

  var globals = typeof window !== 'undefined' ? window : global;
  if (typeof globals.require === 'function') return;

  var modules = {};
  var cache = {};

  var has = function(object, name) {
    return ({}).hasOwnProperty.call(object, name);
  };

  var expand = function(root, name) {
    var results = [], parts, part;
    if (/^\.\.?(\/|$)/.test(name)) {
      parts = [root, name].join('/').split('/');
    } else {
      parts = name.split('/');
    }
    for (var i = 0, length = parts.length; i < length; i++) {
      part = parts[i];
      if (part === '..') {
        results.pop();
      } else if (part !== '.' && part !== '') {
        results.push(part);
      }
    }
    return results.join('/');
  };

  var dirname = function(path) {
    return path.split('/').slice(0, -1).join('/');
  };

  var localRequire = function(path) {
    return function(name) {
      var dir = dirname(path);
      var absolute = expand(dir, name);
      return globals.require(absolute);
    };
  };

  var initModule = function(name, definition) {
    var module = {id: name, exports: {}};
    definition(module.exports, localRequire(name), module);
    var exports = cache[name] = module.exports;
    return exports;
  };

  var require = function(name) {
    var path = expand(name, '.');

    if (has(cache, path)) return cache[path];
    if (has(modules, path)) return initModule(path, modules[path]);

    var dirIndex = expand(path, './index');
    if (has(cache, dirIndex)) return cache[dirIndex];
    if (has(modules, dirIndex)) return initModule(dirIndex, modules[dirIndex]);

    throw new Error('Cannot find module "' + name + '"');
  };

  var define = function(bundle) {
    for (var key in bundle) {
      if (has(bundle, key)) {
        modules[key] = bundle[key];
      }
    }
  }

  globals.require = require;
  globals.require.define = define;
  globals.require.brunch = true;
})();

window.require.define({"collections/attachments": function(exports, require, module) {
  (function() {
    var Attachment,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    Attachment = require("../models/attachment").Attachment;

    /*
      @file: attachments.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description: 
        Backbone collection for handling Attachment objects.
        Used to render the list of attachments fetched for the chosen mail.
    */

    exports.AttachmentsCollection = (function(_super) {

      __extends(AttachmentsCollection, _super);

      function AttachmentsCollection() {
        AttachmentsCollection.__super__.constructor.apply(this, arguments);
      }

      AttachmentsCollection.prototype.model = Attachment;

      AttachmentsCollection.prototype.url = 'getattachments';

      AttachmentsCollection.prototype.setModel = function(areAttachmentsOf) {
        this.areAttachmentsOf = areAttachmentsOf;
        this.url = 'getattachments/' + this.areAttachmentsOf.get("id");
        return this.fetch();
      };

      AttachmentsCollection.prototype.comparator = function(attachment) {
        return attachment.get("fileName");
      };

      return AttachmentsCollection;

    })(Backbone.Collection);

  }).call(this);
  
}});

window.require.define({"collections/mailboxes": function(exports, require, module) {
  (function() {
    var Mailbox,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    Mailbox = require("../models/mailbox").Mailbox;

    /*
      @file: mailboxes.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description: 
        Generic collection of all mailboxes configured by user.
        Uses standard "resourceful" approach for DB API, via it's url.
    */

    exports.MailboxCollection = (function(_super) {

      __extends(MailboxCollection, _super);

      function MailboxCollection() {
        MailboxCollection.__super__.constructor.apply(this, arguments);
      }

      MailboxCollection.prototype.model = Mailbox;

      MailboxCollection.prototype.url = 'mailboxes/';

      MailboxCollection.prototype.activeMailboxes = [];

      MailboxCollection.prototype.initialize = function() {
        return this.on("add", this.addView, this);
      };

      MailboxCollection.prototype.comparator = function(mailbox) {
        return mailbox.get("name");
      };

      MailboxCollection.prototype.addView = function(mail) {
        if (this.view != null) return this.view.addOne(mail);
      };

      MailboxCollection.prototype.updateActiveMailboxes = function() {
        var _this = this;
        this.activeMailboxes = [];
        this.each(function(mb) {
          if (mb.get("checked")) return _this.activeMailboxes.push(mb.get("id"));
        });
        console.log("update mailboxes: " + this.activeMailboxes);
        return this.trigger("change_active_mailboxes", this);
      };

      return MailboxCollection;

    })(Backbone.Collection);

  }).call(this);
  
}});

window.require.define({"collections/mails": function(exports, require, module) {
  (function() {
    var Mail,
      __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    Mail = require("../models/mail").Mail;

    /*
      @file: mails.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description: 
        The collection to store emails - gets populated with the content of the database.
        Uses standard "resourceful" approcha for API.
    */

    exports.MailsCollection = (function(_super) {

      __extends(MailsCollection, _super);

      function MailsCollection() {
        this.fetchNew = __bind(this.fetchNew, this);
        MailsCollection.__super__.constructor.apply(this, arguments);
      }

      MailsCollection.prototype.model = Mail;

      MailsCollection.prototype.url = 'mails/';

      MailsCollection.prototype.timestampNew = new Date().valueOf();

      MailsCollection.prototype.timestampOld = new Date().valueOf();

      MailsCollection.prototype.timestampMiddle = new Date().valueOf();

      MailsCollection.prototype.mailsAtOnce = 100;

      MailsCollection.prototype.mailsShown = 0;

      MailsCollection.prototype.zeroMailsShown = function() {
        return this.mailsShown = 0;
      };

      MailsCollection.prototype.comparator = function(mail) {
        return -mail.get("dateValueOf");
      };

      MailsCollection.prototype.initialize = function() {
        this.on("change_active_mail", this.navigateMail, this);
        setInterval(this.fetchNew, 0.5 * 60 * 1000);
        return window.app.mailboxes.on("change_active_mailboxes", this.zeroMailsShown, this);
      };

      MailsCollection.prototype.navigateMail = function(event) {
        if (this.activeMail != null) {
          return window.app.router.navigate("mail/" + this.activeMail.id);
        } else {
          return console.error("NavigateMail without active mail");
        }
      };

      MailsCollection.prototype.fetchOlder = function(callback) {
        this.url = "mailslist/" + this.timestampOld + "." + this.mailsAtOnce;
        console.log("fetchOlder: " + this.url);
        return this.fetch({
          add: true,
          success: callback
        });
      };

      MailsCollection.prototype.fetchNew = function() {
        this.url = "mailsnew/" + this.timestampNew;
        console.log("fetchNew: " + this.url);
        return this.fetch({
          add: true
        });
      };

      return MailsCollection;

    })(Backbone.Collection);

  }).call(this);
  
}});

window.require.define({"helpers": function(exports, require, module) {
  (function() {

    exports.BrunchApplication = (function() {

      function BrunchApplication() {
        var _this = this;
        $(function() {
          _this.initialize(_this);
          return Backbone.history.start();
        });
      }

      BrunchApplication.prototype.initialize = function() {
        return null;
      };

      return BrunchApplication;

    })();

  }).call(this);
  
}});

window.require.define({"initialize": function(exports, require, module) {
  
  /*
    @file: initialize.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description: 
      Building object used all over the place - collections, AppView, etc
  */

  (function() {
    var AppView, AttachmentsCollection, BrunchApplication, MailNew, MailboxCollection, MailsCollection, MainRouter,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    BrunchApplication = require('helpers').BrunchApplication;

    MainRouter = require('routers/main_router').MainRouter;

    MailboxCollection = require('collections/mailboxes').MailboxCollection;

    MailsCollection = require('collections/mails').MailsCollection;

    AttachmentsCollection = require("collections/attachments").AttachmentsCollection;

    AppView = require('views/app').AppView;

    MailNew = require('models/mail_new').MailNew;

    exports.Application = (function(_super) {

      __extends(Application, _super);

      function Application() {
        Application.__super__.constructor.apply(this, arguments);
      }

      Application.prototype.initialize = function() {
        this.mailboxes = new MailboxCollection;
        this.mails = new MailsCollection;
        this.attachments = new AttachmentsCollection;
        this.router = new MainRouter;
        this.appView = new AppView;
        return this.mailtosend = new MailNew;
      };

      return Application;

    })(BrunchApplication);

    window.app = new exports.Application;

  }).call(this);
  
}});

window.require.define({"models/attachment": function(exports, require, module) {
  (function() {
    var BaseModel,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    BaseModel = require("./models").BaseModel;

    /*
      @file: attachment.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description: 
        Model which defines the attachment
    */

    exports.Attachment = (function(_super) {

      __extends(Attachment, _super);

      function Attachment() {
        Attachment.__super__.constructor.apply(this, arguments);
      }

      return Attachment;

    })(BaseModel);

  }).call(this);
  
}});

window.require.define({"models/mail": function(exports, require, module) {
  (function() {
    var BaseModel,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
      __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

    BaseModel = require("./models").BaseModel;

    /*
      @file: mail.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description: 
        Model which defines the MAIL object.
    */

    exports.Mail = (function(_super) {

      __extends(Mail, _super);

      function Mail() {
        Mail.__super__.constructor.apply(this, arguments);
      }

      Mail.prototype.url = "mails";

      Mail.prototype.initialize = function() {
        this.on("destroy", this.removeView, this);
        return this.on("change", this.redrawView, this);
      };

      Mail.prototype.mailbox = function() {
        if (!this.mailbox) {
          this.mailbox = window.app.mailboxes.get(this.get("mailbox"));
        }
        return this.mailbox;
      };

      Mail.prototype.getColor = function() {
        var box;
        box = window.app.mailboxes.get(this.get("mailbox"));
        if (box) {
          return box.get("color");
        } else {
          return "white";
        }
      };

      Mail.prototype.redrawView = function() {
        if (this.view != null) return this.view.render();
      };

      Mail.prototype.removeView = function() {
        if (this.view != null) return this.view.remove();
      };

      /*
            RENDERING - these functions attr() replace @get "attr", and add some parsing logic.
            To be used in views, to keep the maximum of logic related to mails in one place.
      */

      Mail.prototype.from = function() {
        var obj, out, parsed, _i, _len;
        out = "";
        if (this.get("from")) {
          parsed = JSON.parse(this.get("from"));
          for (_i = 0, _len = parsed.length; _i < _len; _i++) {
            obj = parsed[_i];
            out += obj.name + " <" + obj.address + ">, ";
          }
        }
        return out;
      };

      Mail.prototype.fromShort = function() {
        var obj, out, parsed, _i, _len;
        out = "";
        if (this.get("from")) {
          parsed = JSON.parse(this.get("from"));
          for (_i = 0, _len = parsed.length; _i < _len; _i++) {
            obj = parsed[_i];
            if (obj.name) {
              out += obj.name + " ";
            } else {
              out += obj.address + " ";
            }
          }
        }
        return out;
      };

      Mail.prototype.cc = function() {
        var obj, out, parsed, _i, _len;
        out = "";
        if (this.get("cc")) {
          parsed = JSON.parse(this.get("cc"));
          for (_i = 0, _len = parsed.length; _i < _len; _i++) {
            obj = parsed[_i];
            out += obj.name + " <" + obj.address + ">, ";
          }
        }
        return out;
      };

      Mail.prototype.ccShort = function() {
        var obj, out, parsed, _i, _len;
        out = "";
        if (this.get("cc")) {
          parsed = JSON.parse(this.get("cc"));
          for (_i = 0, _len = parsed.length; _i < _len; _i++) {
            obj = parsed[_i];
            out += obj.name + " ";
          }
        }
        return out;
      };

      Mail.prototype.fromAndCc = function() {
        var obj, out, parsed, _i, _j, _len, _len2;
        out = "";
        if (this.get("from")) {
          parsed = JSON.parse(this.get("from"));
          for (_i = 0, _len = parsed.length; _i < _len; _i++) {
            obj = parsed[_i];
            out += obj.name + " <" + obj.address + ">, ";
          }
        }
        if (this.get("cc")) {
          parsed = JSON.parse(this.get("cc"));
          for (_j = 0, _len2 = parsed.length; _j < _len2; _j++) {
            obj = parsed[_j];
            out += obj.name + " <" + obj.address + ">, ";
          }
        }
        return out;
      };

      Mail.prototype.date = function() {
        var parsed;
        parsed = new Date(this.get("date"));
        return parsed.toUTCString();
      };

      Mail.prototype.subjectResponse = function(mode) {
        var subject;
        if (mode == null) mode = "answer";
        subject = this.get("subject");
        switch (mode) {
          case "answer":
            return "RE: " + subject.replace(/RE:?/, "");
          case "answer_all":
            return "RE: " + subject.replace(/RE:?/, "");
          case "forward":
            return "FWD: " + subject.replace(/FWD:?/, "");
          default:
            return subject;
        }
      };

      Mail.prototype.ccResponse = function(mode) {
        if (mode == null) mode = "answer";
        switch (mode) {
          case "answer_all":
            return this.cc();
          default:
            return "";
        }
      };

      Mail.prototype.toResponse = function(mode) {
        if (mode == null) mode = "answer";
        switch (mode) {
          case "answer":
            return this.from();
          case "answer_all":
            return this.from();
          default:
            return "";
        }
      };

      Mail.prototype.text = function() {
        return this.get("text").replace(/\r\n|\r|\n/g, "<br />");
      };

      Mail.prototype.html = function() {
        var exp, expression, string;
        expression = new RegExp("(<style>(.|\s)*?</style>)", "gi");
        exp = /\/(<style>(.|\s)*?<\/style>)\/ig/;
        string = new String(this.get("html"));
        return string.replace(expression, "");
      };

      Mail.prototype.hasHtml = function() {
        var html;
        html = this.get("html");
        return (html != null) && html !== "";
      };

      Mail.prototype.hasAttachments = function() {
        return this.get("hasAttachments");
      };

      Mail.prototype.htmlOrText = function() {
        if (this.hasHtml()) {
          return this.html();
        } else {
          return this.text();
        }
      };

      /*
          Changing mail's properties - read and flagged
          TODO: synchronise them with remote servers.
      */

      Mail.prototype.isUnread = function() {
        return !this.get("read");
      };

      Mail.prototype.setRead = function(read) {
        var box, flags, flagsPrev;
        if (read == null) read = true;
        flags = JSON.parse(this.get("flags"));
        if (read) {
          if (__indexOf.call(flags, "\\Seen") < 0) {
            flags.push("\\Seen");
            box = window.app.mailboxes.get(this.get("mailbox"));
            if (box != null) {
              box.set("new_messages", (parseInt(box != null ? box.get("new_messages") : void 0)) - 1);
            }
          }
          this.set({
            "read": true
          });
        } else {
          flagsPrev = flags.length;
          flags = $.grep(flags, function(val) {
            return val !== "\\Seen";
          });
          if (flagsPrev !== flags.length) {
            box = window.app.mailboxes.get(this.get("mailbox"));
            if (box != null) {
              box.set("new_messages", (parseInt(box != null ? box.get("new_messages") : void 0)) + 1);
            }
          }
          this.set({
            "read": false
          });
        }
        return this.set({
          "flags": JSON.stringify(flags)
        });
      };

      Mail.prototype.isFlagged = function() {
        return this.get("flagged");
      };

      Mail.prototype.setFlagged = function(flagged) {
        var flags;
        if (flagged == null) flagged = true;
        flags = JSON.parse(this.get("flags"));
        if (flagged) {
          if (__indexOf.call(flags, "\\Flagged") < 0) flags.push("\\Flagged");
        } else {
          flags = $.grep(flags, function(val) {
            return val !== "\\Flagged";
          });
        }
        this.set({
          "flagged": flagged
        });
        return this.set({
          "flags": JSON.stringify(flags)
        });
      };

      return Mail;

    })(BaseModel);

  }).call(this);
  
}});

window.require.define({"models/mail_new": function(exports, require, module) {
  (function() {
    var BaseModel,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    BaseModel = require("./models").BaseModel;

    /*
      @file: mail_new.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description: 
        Model which defines the new MAIL object (to send).
        
        In fact, it's just a container of data, to send easily to sendmail controller.
    */

    exports.MailNew = (function(_super) {

      __extends(MailNew, _super);

      function MailNew() {
        MailNew.__super__.constructor.apply(this, arguments);
      }

      MailNew.prototype.url = "sendmail";

      return MailNew;

    })(BaseModel);

  }).call(this);
  
}});

window.require.define({"models/mailbox": function(exports, require, module) {
  (function() {
    var BaseModel,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    BaseModel = require("./models").BaseModel;

    /*
      @file: mailbox.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description: 
        A model which defines the MAILBOX object.
        MAILBOX stocks all the data necessary for a successful connection to IMAP and SMTP servers,
        and all the data relative to this mailbox, internal to the application.
    */

    exports.Mailbox = (function(_super) {

      __extends(Mailbox, _super);

      function Mailbox() {
        Mailbox.__super__.constructor.apply(this, arguments);
      }

      Mailbox.urlRoot = 'mailboxes/';

      Mailbox.url = 'mailboxes/';

      Mailbox.prototype.defaults = {
        'checked': true,
        'config': 0,
        'name': "box",
        'login': "login",
        'pass': "pass",
        'SMTP_server': "smtp.gmail.com",
        'SMTP_ssl': true,
        'SMTP_send_as': "support@mycozycloud.com",
        'IMAP_server': "imap.gmail.com",
        'IMAP_port': 993,
        'IMAP_secure': true,
        'color': "orange"
      };

      Mailbox.prototype.initialize = function() {
        return this.on("destroy", this.removeView, this);
      };

      Mailbox.prototype.redrawView = function() {
        if (this.view != null) return this.view.render();
      };

      Mailbox.prototype.removeView = function() {
        if (this.view != null) return this.view.remove();
      };

      Mailbox.prototype.IMAPLastFetchedDate = function() {
        var parsed;
        parsed = new Date(this.get("IMAP_last_fetched_date"));
        return parsed.toUTCString();
      };

      return Mailbox;

    })(BaseModel);

  }).call(this);
  
}});

window.require.define({"models/models": function(exports, require, module) {
  
  /*
    @file: models.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description: 
      Base class which contains methods common for all the models.
      Might get useful at some point, even though it's not visible yet...
  */

  (function() {
    var __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    exports.BaseModel = (function(_super) {

      __extends(BaseModel, _super);

      function BaseModel() {
        BaseModel.__super__.constructor.apply(this, arguments);
      }

      BaseModel.prototype.debug = true;

      BaseModel.prototype.isNew = function() {
        return !(this.id != null);
      };

      BaseModel.prototype.prerender = function() {
        var prop, val, _ref;
        if (this.debug != null) console.log("Prerender");
        _ref = this.attributes;
        for (prop in _ref) {
          val = _ref[prop];
          this["_" + prop] = this[prop](val);
          if (this["render_" + prop] != null) {
            if (this.debug != null) {
              console.log("rendering " + prop + " -> __" + prop);
            }
            this["_" + prop] = this["_render_" + prop](val);
          } else {
            if (this.debug != null) console.log("copying " + prop + " -> __" + prop);
            this["__" + prop] = this.attributes[prop];
          }
        }
        if (this.debug != null) console.log(this);
        return this;
      };

      return BaseModel;

    })(Backbone.Model);

  }).call(this);
  
}});

window.require.define({"routers/main_router": function(exports, require, module) {
  (function() {
    var Mail,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    Mail = require("../models/mail").Mail;

    /*
      @file: main_router.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description: 
        The application router.
        Trying to recreate the minimum of object on every reroute.
    */

    exports.MainRouter = (function(_super) {

      __extends(MainRouter, _super);

      function MainRouter() {
        MainRouter.__super__.constructor.apply(this, arguments);
      }

      MainRouter.prototype.routes = {
        '': 'home',
        'inbox': 'home',
        'new-mail': 'new',
        'config-mailboxes': 'configMailboxes'
      };

      MainRouter.prototype.initialize = function() {
        return this.route(/^mail\/(.*?)$/, 'mail');
      };

      MainRouter.prototype.home = function() {
        app.appView.setLayoutMails();
        $(".menu_option").removeClass("active");
        return $("#inboxbutton").addClass("active");
      };

      MainRouter.prototype["new"] = function() {
        app.appView.setLayoutComposeMail();
        $(".menu_option").removeClass("active");
        return $("#newmailbutton").addClass("active");
      };

      MainRouter.prototype.configMailboxes = function() {
        app.appView.setLayoutMailboxes();
        $(".menu_option").removeClass("active");
        return $("#mailboxesbutton").addClass("active");
      };

      MainRouter.prototype.mail = function(path) {
        this.home();
        if (app.mails.get(path) != null) {
          app.mails.activeMail = app.mails.get(path);
          return app.mails.trigger("change_active_mail");
        } else {
          app.mails.activeMail = new Mail({
            id: path
          });
          app.mails.activeMail.url = "mails/" + path;
          return app.mails.activeMail.fetch({
            success: function() {
              return app.mails.trigger("change_active_mail");
            }
          });
        }
      };

      return MainRouter;

    })(Backbone.Router);

  }).call(this);
  
}});

window.require.define({"views/app": function(exports, require, module) {
  (function() {
    var MailboxesList, MailboxesListNew, MailsColumn, MailsCompose, MailsElement, MenuMailboxesList, MessageBox,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    MailboxesList = require('../views/mailboxes_list').MailboxesList;

    MailboxesListNew = require('../views/mailboxes_list_new').MailboxesListNew;

    MenuMailboxesList = require('../views/menu_mailboxes_list').MenuMailboxesList;

    MailsColumn = require('../views/mails_column').MailsColumn;

    MailsElement = require('../views/mails_element').MailsElement;

    MailsCompose = require('../views/mails_compose').MailsCompose;

    MessageBox = require('views/message_box').MessageBox;

    /*
      @file: app.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description: 
        The application's main view - creates other views, lays things out.
    */

    exports.AppView = (function(_super) {

      __extends(AppView, _super);

      function AppView() {
        AppView.__super__.constructor.apply(this, arguments);
      }

      AppView.prototype.el = 'body';

      AppView.prototype.initialize = function() {
        window.onresize = this.resize;
        $(this.el).html(require('./templates/app'));
        this.containerMenu = this.$("#menu_container");
        this.containerContent = this.$("#content");
        this.viewMessageBox = new MessageBox(this.$("#message_box"), window.app.mailboxes, window.app.mails);
        return this.setLayoutMenu();
      };

      AppView.prototype.resize = function() {
        var viewport;
        viewport = function() {
          var a, e;
          e = window;
          a = "inner";
          if (!("innerWidth" in window)) {
            a = "client";
            e = document.documentElement || document.body;
          }
          return e[a + "Height"];
        };
        $("body").height(viewport() - 10);
        $("#content").height(viewport() - 10);
        return $(".column").height(viewport() - 10);
      };

      AppView.prototype.setLayoutMenu = function() {
        this.containerMenu.html(require('./templates/menu'));
        window.app.viewMenu = new MenuMailboxesList(this.$("#menu_mailboxes"), window.app.mailboxes);
        window.app.mailboxes.reset();
        return window.app.mailboxes.fetch({
          success: function() {
            window.app.mailboxes.updateActiveMailboxes();
            window.app.mailboxes.trigger("change_active_mailboxes");
            console.log("Initial menu mailboxes load OK");
            return window.app.viewMenu.render();
          }
        });
      };

      AppView.prototype.setLayoutMailboxes = function() {
        this.setLayoutMenu();
        this.containerContent.html(require('./templates/_layouts/layout_mailboxes'));
        window.app.viewMailboxes = new MailboxesList(this.$("#mail_list_container"), window.app.mailboxes);
        window.app.viewMailboxesNew = new MailboxesListNew(this.$("#add_mail_button_container"), window.app.mailboxes);
        window.app.viewMailboxesNew.render();
        window.app.mailboxes.reset();
        window.app.mailboxes.fetch({
          success: function() {
            window.app.mailboxes.updateActiveMailboxes();
            return console.log("Initial mailbox view mailboxes load OK");
          }
        });
        return this.resize();
      };

      AppView.prototype.setLayoutComposeMail = function() {
        this.setLayoutMenu();
        this.containerContent.html(require('./templates/_layouts/layout_compose_mail'));
        window.app.viewComposeMail = new MailsCompose(this.$("#compose_mail_container"), window.app.mailboxes);
        window.app.mailboxes.reset();
        window.app.mailboxes.fetch({
          success: function() {
            window.app.mailboxes.updateActiveMailboxes();
            console.log("Initial compose view mailboxes load OK");
            return window.app.viewComposeMail.render();
          }
        });
        return this.resize();
      };

      AppView.prototype.setLayoutMails = function() {
        this.setLayoutMenu();
        this.containerContent.html(require('./templates/_layouts/layout_mails'));
        window.app.viewMailsList = new MailsColumn(this.$("#column_mails_list"), window.app.mails);
        window.app.viewMailsList.render();
        window.app.view_mail = new MailsElement(this.$("#column_mail"), window.app.mails);
        window.app.mailboxes.reset();
        window.app.mailboxes.fetch({
          success: function() {
            console.log("Initial mails mailboxes load OK");
            return window.app.mails.fetchOlder(function() {
              console.log("Initial mails mails load OK");
              return window.app.mailboxes.updateActiveMailboxes();
            });
          }
        });
        return this.resize();
      };

      return AppView;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/mailboxes_list": function(exports, require, module) {
  (function() {
    var Mailbox, MailboxesListElement,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    Mailbox = require("../models/mailbox").Mailbox;

    MailboxesListElement = require("../views/mailboxes_list_element").MailboxesListElement;

    /*
      @file: mailboxes_list.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description: 
        Displays the list of configured mailboxes.
    */

    exports.MailboxesList = (function(_super) {

      __extends(MailboxesList, _super);

      MailboxesList.prototype.id = "mailboxeslist";

      MailboxesList.prototype.className = "mailboxes";

      function MailboxesList(el, collection) {
        this.el = el;
        this.collection = collection;
        MailboxesList.__super__.constructor.call(this);
        this.collection.view = this;
      }

      MailboxesList.prototype.initialize = function() {
        return this.collection.on('reset', this.render, this);
      };

      MailboxesList.prototype.addOne = function(mail) {
        var box;
        box = new MailboxesListElement(mail, mail.collection);
        return $(this.el).append(box.render().el);
      };

      MailboxesList.prototype.render = function() {
        var _this = this;
        $(this.el).html("");
        this.collection.each(function(m) {
          m.isEdit = false;
          return _this.addOne(m);
        });
        return this;
      };

      return MailboxesList;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/mailboxes_list_element": function(exports, require, module) {
  (function() {
    var Mailbox,
      __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    Mailbox = require("../models/mailbox").Mailbox;

    /*
      @file: mailboxes_list_element.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description: 
        The element of the list of mailboxes.
        mailboxes_list -> mailboxes_list_element
    */

    exports.MailboxesListElement = (function(_super) {

      __extends(MailboxesListElement, _super);

      MailboxesListElement.prototype.className = "mailbox_well well";

      MailboxesListElement.prototype.isEdit = false;

      MailboxesListElement.prototype.events = {
        "click .edit_mailbox": "buttonEdit",
        "click .cancel_edit_mailbox": "buttonCancel",
        "click .save_mailbox": "buttonSave",
        "click .delete_mailbox": "buttonDelete",
        "input input#name": "updateName",
        "change #color": "updateColor",
        "click .fetch_mailbox": "buttonFetchMailbox",
        "click .fetch_mails": "buttonFetchMails"
      };

      function MailboxesListElement(model, collection) {
        this.model = model;
        this.collection = collection;
        this.buttonDelete = __bind(this.buttonDelete, this);
        MailboxesListElement.__super__.constructor.call(this);
        this.model.view = this;
      }

      MailboxesListElement.prototype.initialize = function() {
        var model, view;
        view = this;
        return model = this.model;
      };

      MailboxesListElement.prototype.updateName = function(event) {
        return this.model.set("name", $(event.target).val());
      };

      MailboxesListElement.prototype.updateColor = function(event) {
        return this.model.set("color", $(event.target).val());
      };

      MailboxesListElement.prototype.buttonFetchMails = function(event) {
        $(event.target).addClass("disabled").removeClass("fetch_mails").text("Loading...");
        return $.ajax("fetchmailbox/" + this.model.id, {
          complete: function() {
            window.app.mails.fetchNew();
            return $(event.target).removeClass("disabled").addClass("fetch_mails").text("Check for new mail complete");
          }
        });
      };

      MailboxesListElement.prototype.buttonFetchMailbox = function(event) {
        var view;
        view = this;
        $(event.target).addClass("disabled").removeClass("fetch_mailbox").text("Loading...");
        this.model.url = 'mailboxes/' + this.model.id;
        return this.model.fetch({
          success: function() {
            $(event.target).removeClass("disabled").addClass("fetch_mailbox").text("Status verified");
            return view.render();
          }
        });
      };

      MailboxesListElement.prototype.buttonEdit = function(event) {
        this.model.isEdit = true;
        return this.render();
      };

      MailboxesListElement.prototype.buttonCancel = function(event) {
        if (this.model.isNew()) this.model.destroy();
        this.model.isEdit = false;
        return this.render();
      };

      MailboxesListElement.prototype.buttonSave = function(event) {
        var data, input,
          _this = this;
        $(event.target).addClass("disabled").removeClass("buttonSave");
        input = this.$(".content");
        data = {};
        input.each(function(i) {
          return data[input[i].id] = input[i].value;
        });
        this.model.isEdit = false;
        if (this.model.isNew()) {
          return this.model.save(data, {
            success: function(modelSaved, response) {
              $.ajax("importmailbox/" + modelSaved.id, {
                complete: function() {
                  console.log("importmailbox/" + modelSaved.id);
                  return window.app.appView.viewMessageBox.renderMailboxNewSuccess();
                }
              });
              return _this.render();
            }
          });
        } else {
          return this.model.save(data, {
            success: function() {
              window.app.appView.viewMessageBox.renderMailboxUpdateSuccess();
              return _this.render();
            }
          });
        }
      };

      MailboxesListElement.prototype.buttonDelete = function(event) {
        $(event.target).addClass("disabled").removeClass("delete_mailbox");
        return this.model.destroy();
      };

      MailboxesListElement.prototype.render = function() {
        var template;
        if (this.model.isEdit) {
          template = require('./templates/_mailbox/mailbox_edit');
        } else {
          template = require('./templates/_mailbox/mailbox');
        }
        $(this.el).html(template({
          "model": this.model
        }));
        return this;
      };

      return MailboxesListElement;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/mailboxes_list_new": function(exports, require, module) {
  (function() {
    var Mailbox,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    Mailbox = require("../models/mailbox").Mailbox;

    /*
      @file: mailboxes_list_new.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description: 
        The toolbar to add a new mailbox.
        mailboxes_list -> mailboxes_list_new
    */

    exports.MailboxesListNew = (function(_super) {

      __extends(MailboxesListNew, _super);

      MailboxesListNew.prototype.id = "mailboxeslist_new";

      MailboxesListNew.prototype.className = "mailboxes_new";

      MailboxesListNew.prototype.events = {
        "click #add_mailbox": 'addMailbox'
      };

      function MailboxesListNew(el, collection) {
        this.el = el;
        this.collection = collection;
        MailboxesListNew.__super__.constructor.call(this);
      }

      MailboxesListNew.prototype.addMailbox = function(event) {
        var newbox;
        event.preventDefault();
        newbox = new Mailbox;
        newbox.isEdit = true;
        return this.collection.add(newbox);
      };

      MailboxesListNew.prototype.render = function() {
        $(this.el).html(require('./templates/_mailbox/mailbox_new'));
        return this;
      };

      return MailboxesListNew;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/mails_answer": function(exports, require, module) {
  (function() {
    var Mail, MailNew,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    Mail = require("../models/mail").Mail;

    MailNew = require("../models/mail_new").MailNew;

    /*
      @file: mails_answer.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description: 
        The mail response view. Created when user clicks "answer"
    */

    exports.MailsAnswer = (function(_super) {

      __extends(MailsAnswer, _super);

      function MailsAnswer(el, mail, mailtosend) {
        this.el = el;
        this.mail = mail;
        this.mailtosend = mailtosend;
        MailsAnswer.__super__.constructor.call(this);
        this.mail.on("change", this.render, this);
        this.mailtosend.on("change_mode", this.render, this);
      }

      MailsAnswer.prototype.events = {
        "click a#send_button": 'prepareSend',
        "click a#mail_detailed_view_button": 'viewAdvanced'
      };

      MailsAnswer.prototype.prepareSend = function(event) {
        var data, el, input;
        $(event.target).addClass("disabled").removeClass("buttonSave");
        this.$(".content").addClass("disabled");
        input = this.$(".content");
        data = {};
        input.each(function(i) {
          return data[input[i].id] = input[i].value;
        });
        this.mailtosend.url = "sendmail/" + this.mail.get("mailbox");
        el = this.el;
        this.mailtosend.save(data, {
          success: function() {
            console.log("sent!");
            $(el).html(require('./templates/_mail/mail_sent'));
            return window.app.appView.viewMessageBox.renderMessageSentSuccess();
          },
          error: function() {
            console.log("error!");
            return window.app.appView.viewMessageBox.renderMessageSentError();
          }
        });
        return console.log("sending mail: " + this.mailtosend);
      };

      MailsAnswer.prototype.setBasic = function(show) {
        if (show == null) show = true;
        if (show) {
          return this.$("#mail_basic").show();
        } else {
          return this.$("#mail_basic").hide();
        }
      };

      MailsAnswer.prototype.setTo = function(show) {
        if (show == null) show = true;
        if (show) {
          return this.$("#mail_to").show();
        } else {
          return this.$("#mail_to").hide();
        }
      };

      MailsAnswer.prototype.setAdvanced = function(show) {
        if (show == null) show = true;
        if (show) {
          return this.$("#mail_advanced").show();
        } else {
          return this.$("#mail_advanced").hide();
        }
      };

      MailsAnswer.prototype.viewAdvanced = function() {
        this.setBasic(false);
        this.setTo(true);
        return this.setAdvanced(true);
      };

      MailsAnswer.prototype.render = function() {
        var editor, template;
        $(this.el).html("");
        template = require('./templates/_mail/mail_answer');
        $(this.el).html(template({
          "model": this.mail,
          "mailtosend": this.mailtosend
        }));
        try {
          editor = new wysihtml5.Editor("html", {
            toolbar: "wysihtml5-toolbar",
            parserRules: wysihtml5ParserRules,
            stylesheets: ["http://yui.yahooapis.com/2.9.0/build/reset/reset-min.css", "css/editor.css"]
          });
        } catch (error) {
          console.log(error);
        }
        this.setBasic(true);
        this.setTo(false);
        this.setAdvanced(false);
        return this;
      };

      return MailsAnswer;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/mails_attachments_list": function(exports, require, module) {
  (function() {
    var Attachment, AttachmentsCollection, MailsAttachmentsListElement,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    Attachment = require("../models/attachment").Attachment;

    AttachmentsCollection = require("../collections/attachments").AttachmentsCollection;

    MailsAttachmentsListElement = require("./mails_attachments_list_element").MailsAttachmentsListElement;

    /*
      @file: mails_attachments_list.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description: 
        The list of attachments, created every time user displays a mail.
    */

    exports.MailsAttachmentsList = (function(_super) {

      __extends(MailsAttachmentsList, _super);

      function MailsAttachmentsList(el, model) {
        this.el = el;
        this.model = model;
        MailsAttachmentsList.__super__.constructor.call(this);
      }

      MailsAttachmentsList.prototype.initialize = function() {
        window.app.attachments.on('reset', this.render, this);
        window.app.attachments.on('add', this.addOne, this);
        return window.app.attachments.setModel(this.model);
      };

      MailsAttachmentsList.prototype.addOne = function(attachment) {
        var box;
        box = new MailsAttachmentsListElement(attachment, this.collection);
        return $(this.el).append(box.render().el);
      };

      MailsAttachmentsList.prototype.render = function() {
        var _this = this;
        $(this.el).html("");
        window.app.attachments.each(function(attachment) {
          return _this.addOne(attachment);
        });
        return this;
      };

      return MailsAttachmentsList;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/mails_attachments_list_element": function(exports, require, module) {
  
  /*
    @file: mails_attachments_list_element.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description: 
      Renders clickable attachments link.
  */

  (function() {
    var __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    exports.MailsAttachmentsListElement = (function(_super) {

      __extends(MailsAttachmentsListElement, _super);

      MailsAttachmentsListElement.prototype.tagName = "p";

      function MailsAttachmentsListElement(attachment) {
        this.attachment = attachment;
        MailsAttachmentsListElement.__super__.constructor.call(this);
        this.attachment.view = this;
      }

      MailsAttachmentsListElement.prototype.render = function() {
        var template;
        template = require('./templates/_attachment/attachment_element');
        $(this.el).html(template({
          "attachment": this.attachment
        }));
        return this;
      };

      return MailsAttachmentsListElement;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/mails_column": function(exports, require, module) {
  (function() {
    var Mail, MailsList, MailsListMore,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    Mail = require("../models/mail").Mail;

    MailsList = require("../views/mails_list").MailsList;

    MailsListMore = require("../views/mails_list_more").MailsListMore;

    /*
      @file: mails_column.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description: 
        The view of the central column - the one which holds the list of mail.
    */

    exports.MailsColumn = (function(_super) {

      __extends(MailsColumn, _super);

      MailsColumn.prototype.id = "mailboxeslist";

      MailsColumn.prototype.className = "mailboxes";

      function MailsColumn(el, collection) {
        this.el = el;
        this.collection = collection;
        MailsColumn.__super__.constructor.call(this);
      }

      MailsColumn.prototype.render = function() {
        $(this.el).html(require('./templates/_mail/mails'));
        this.viewMailsList = new MailsList(this.$("#mails_list_container"), this.collection);
        this.viewMailsListMore = new MailsListMore(this.$("#button_load_more_mails"), this.collection);
        this.viewMailsList.render();
        this.viewMailsListMore.render();
        return this;
      };

      return MailsColumn;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/mails_compose": function(exports, require, module) {
  (function() {
    var Mail, MailNew, MailsAnswer,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    Mail = require("../models/mail").Mail;

    MailsAnswer = require("../views/mails_answer").MailsAnswer;

    MailNew = require("../models/mail_new").MailNew;

    /*
      @file: mails_compose.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description: 
        The new mail view, gives the choixe between configured mailboxes and makes it possible to send data.
    */

    exports.MailsCompose = (function(_super) {

      __extends(MailsCompose, _super);

      MailsCompose.prototype.events = {
        "click a#send_button": 'prepareSend'
      };

      function MailsCompose(el, collection) {
        this.el = el;
        this.collection = collection;
        MailsCompose.__super__.constructor.call(this);
        this.mailtosend = new MailNew();
      }

      MailsCompose.prototype.prepareSend = function(event) {
        var data, el, input, _ref;
        $(event.target).addClass("disabled").removeClass("buttonSave");
        this.$(".content").addClass("disabled");
        input = this.$(".content");
        data = {};
        input.each(function(i) {
          return data[input[i].id] = input[i].value;
        });
        this.mailtosend.url = "sendmail/" + ((_ref = window.app.mailboxes.get(data["mailbox"])) != null ? _ref.get("id") : void 0);
        el = this.el;
        this.mailtosend.save(data, {
          success: function() {
            console.log("sent!");
            $(el).html(require('./templates/_mail/mail_sent'));
            return window.app.appView.viewMessageBox.renderMessageSentSuccess();
          },
          error: function() {
            console.log("error!");
            return window.app.appView.viewMessageBox.renderMessageSentError();
          }
        });
        return console.log("sending mail: " + this.mailtosend);
      };

      MailsCompose.prototype.render = function() {
        var editor, template;
        template = require('./templates/_mail/mail_compose');
        $(this.el).html(template({
          "models": this.collection.models
        }));
        try {
          return editor = new wysihtml5.Editor("html", {
            toolbar: "wysihtml5-toolbar",
            parserRules: wysihtml5ParserRules,
            stylesheets: ["http://yui.yahooapis.com/2.9.0/build/reset/reset-min.css", "css/editor.css"]
          });
        } catch (error) {
          return console.log(error.toString());
        }
      };

      return MailsCompose;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/mails_element": function(exports, require, module) {
  (function() {
    var Mail, MailNew, MailsAnswer, MailsAttachmentsList,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    Mail = require("../models/mail").Mail;

    MailsAnswer = require("../views/mails_answer").MailsAnswer;

    MailNew = require("../models/mail_new").MailNew;

    MailsAttachmentsList = require("../views/mails_attachments_list").MailsAttachmentsList;

    /*
      @file: mails_element.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description: 
        The mail view. Displays all data & options.
        Also, handles buttons.
    */

    exports.MailsElement = (function(_super) {

      __extends(MailsElement, _super);

      function MailsElement(el, collection) {
        this.el = el;
        this.collection = collection;
        MailsElement.__super__.constructor.call(this);
        this.collection.on("change_active_mail", this.render, this);
      }

      MailsElement.prototype.events = {
        "click a#button_answer_all": 'buttonAnswerAll',
        "click a#button_answer": 'buttonAnswer',
        "click a#button_forward": 'buttonForward',
        "click a#button_unread": 'buttonUnread',
        "click a#button_flagged": 'buttonFlagged'
      };

      /*
            CLICK ACTIONS
      */

      MailsElement.prototype.createAnswerView = function() {
        if (!window.app.viewAnswer) {
          console.log("create new answer view");
          window.app.viewAnswer = new MailsAnswer(this.$("#answer_form"), this.collection.activeMail, window.app.mailtosend);
          return window.app.viewAnswer.render();
        }
      };

      MailsElement.prototype.scrollDown = function() {
        return setTimeout(function() {
          return $("#column_mail").animate({
            scrollTop: 2 * $("#column_mail").outerHeight(true)
          }, 750);
        }, 250);
      };

      MailsElement.prototype.buttonAnswerAll = function() {
        console.log("answer all");
        this.createAnswerView();
        window.app.mailtosend.set({
          mode: "answer_all"
        });
        window.app.viewAnswer.setBasic(true);
        window.app.viewAnswer.setTo(false);
        window.app.viewAnswer.setAdvanced(false);
        window.app.mailtosend.trigger("change_mode");
        return this.scrollDown();
      };

      MailsElement.prototype.buttonAnswer = function() {
        console.log("answer");
        this.createAnswerView();
        window.app.mailtosend.set({
          mode: "answer"
        });
        window.app.viewAnswer.setBasic(true);
        window.app.viewAnswer.setTo(false);
        window.app.viewAnswer.setAdvanced(false);
        window.app.mailtosend.trigger("change_mode");
        return this.scrollDown();
      };

      MailsElement.prototype.buttonForward = function() {
        console.log("forward");
        this.createAnswerView();
        window.app.mailtosend.set({
          mode: "forward"
        });
        window.app.mailtosend.trigger("change_mode");
        window.app.viewAnswer.setBasic(true);
        window.app.viewAnswer.setTo(true);
        window.app.viewAnswer.setAdvanced(false);
        return this.scrollDown();
      };

      MailsElement.prototype.buttonUnread = function() {
        console.log("unread");
        this.collection.activeMail.setRead(false);
        this.collection.activeMail.url = "mails/" + this.collection.activeMail.get("id");
        return this.collection.activeMail.save();
      };

      MailsElement.prototype.buttonFlagged = function() {
        if (this.collection.activeMail.isFlagged()) {
          console.log("unflagged");
          this.collection.activeMail.setFlagged(false);
        } else {
          this.collection.activeMail.setFlagged(true);
          console.log("flagged");
        }
        this.collection.activeMail.url = "mails/" + this.collection.activeMail.get("id");
        return this.collection.activeMail.save();
      };

      MailsElement.prototype.render = function() {
        var template,
          _this = this;
        if (window.app.viewAnswer) {
          delete window.app.viewAnswer;
          console.log("delete answer view");
        }
        $(this.el).html("");
        if (this.collection.activeMail != null) {
          template = require('./templates/_mail/mail_big');
          $(this.el).html(template({
            "model": this.collection.activeMail
          }));
          if (this.collection.activeMail.hasHtml()) {
            setTimeout(function() {
              $("#mail_content_html").contents().find("html").html(_this.collection.activeMail.html());
              $("#mail_content_html").contents().find("head").append('<link rel="stylesheet" href="css/reset_bootstrap.css">');
              $("#mail_content_html").contents().find("head").append('<base target="_blank">');
              return $("#mail_content_html").height($("#mail_content_html").contents().find("html").height());
            }, 1);
            window.app.viewAttachments = new MailsAttachmentsList($("#attachments_list"), this.collection.activeMail);
          }
        }
        return this;
      };

      return MailsElement;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/mails_list": function(exports, require, module) {
  (function() {
    var Mail, MailsListElement,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    Mail = require("../models/mail").Mail;

    MailsListElement = require("./mails_list_element").MailsListElement;

    /*
      @file: mails_list.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description: 
        View to generate the list of mails - the second column from the left.
        Uses MailsListElement to generate each mail's view
    */

    exports.MailsList = (function(_super) {

      __extends(MailsList, _super);

      MailsList.prototype.id = "mails_list";

      function MailsList(el, collection) {
        this.el = el;
        this.collection = collection;
        MailsList.__super__.constructor.call(this);
        this.collection.view = this;
      }

      MailsList.prototype.initialize = function() {
        this.collection.on('reset', this.render, this);
        return this.collection.on("add", this.treatAdd, this);
      };

      MailsList.prototype.treatAdd = function(mail) {
        var dateValueOf;
        dateValueOf = mail.get("dateValueOf");
        if (dateValueOf <= window.app.mails.timestampMiddle) {
          if (dateValueOf < window.app.mails.timestampOld) {
            window.app.mails.timestampOld = dateValueOf;
          }
          return this.addOne(mail);
        } else {
          if (dateValueOf > window.app.mails.timestampNew) {
            window.app.mails.timestampNew = dateValueOf;
          }
          return this.addNew(mail);
        }
      };

      MailsList.prototype.addOne = function(mail) {
        var box;
        box = new MailsListElement(mail, window.app.mails);
        return $(this.el).append(box.render().el);
      };

      MailsList.prototype.addNew = function(mail) {
        var box;
        box = new MailsListElement(mail, window.app.mails);
        return $(this.el).prepend(box.render().el);
      };

      MailsList.prototype.render = function() {
        var col,
          _this = this;
        $(this.el).html("");
        col = this.collection;
        this.collection.each(function(m) {
          return _this.addOne(m);
        });
        return this;
      };

      return MailsList;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/mails_list_element": function(exports, require, module) {
  (function() {
    var Mail,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
      __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

    Mail = require("../models/mail").Mail;

    /*
      @file: mails_list_element.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description: 
        The element on the list of mails. Reacts for events, and stuff.
    */

    exports.MailsListElement = (function(_super) {

      __extends(MailsListElement, _super);

      MailsListElement.prototype.tagName = "tr";

      MailsListElement.prototype.active = false;

      MailsListElement.prototype.visible = true;

      MailsListElement.prototype.events = {
        "click": "setActiveMail"
      };

      function MailsListElement(model, collection) {
        this.model = model;
        this.collection = collection;
        MailsListElement.__super__.constructor.call(this);
        this.model.view = this;
        window.app.mailboxes.on("change_active_mailboxes", this.checkVisible, this);
      }

      MailsListElement.prototype.setActiveMail = function(event) {
        var _ref, _ref2, _ref3, _ref4;
        if ((_ref = this.collection.activeMail) != null) {
          if ((_ref2 = _ref.view) != null) _ref2.active = false;
        }
        if ((_ref3 = this.collection.activeMail) != null) {
          if ((_ref4 = _ref3.view) != null) _ref4.render();
        }
        this.collection.activeMail = this.model;
        this.collection.activeMail.view.active = true;
        this.render();
        this.collection.activeMail.setRead();
        this.collection.activeMail.url = "mails/" + this.collection.activeMail.get("id");
        this.collection.activeMail.save({
          "read": true
        });
        return this.collection.trigger("change_active_mail");
      };

      MailsListElement.prototype.checkVisible = function() {
        var state, _ref;
        state = (_ref = this.model.get("mailbox"), __indexOf.call(window.app.mailboxes.activeMailboxes, _ref) >= 0);
        if (state !== this.visible) {
          this.visible = state;
          this.render();
        }
        if (state) return window.app.mails.mailsShown++;
      };

      MailsListElement.prototype.render = function() {
        var template;
        template = require('./templates/_mail/mail_list');
        $(this.el).html(template({
          "model": this.model,
          "active": this.active,
          "visible": this.visible
        }));
        return this;
      };

      return MailsListElement;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/mails_list_more": function(exports, require, module) {
  (function() {
    var Mail,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    Mail = require("../models/mail").Mail;

    /*
      @file: mails_list_more.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description: 
        The view with the "load more" button.
        Also displays info on how many messages are visible in this filer, and how many are effectiveley downloaded.
    */

    exports.MailsListMore = (function(_super) {

      __extends(MailsListMore, _super);

      MailsListMore.prototype.clickable = true;

      function MailsListMore(el, collection) {
        this.el = el;
        this.collection = collection;
        MailsListMore.__super__.constructor.call(this);
      }

      MailsListMore.prototype.initialize = function() {
        this.collection.on('reset', this.render, this);
        this.collection.on('add', this.render, this);
        return window.app.mailboxes.on("change_active_mailboxes", this.render, this);
      };

      MailsListMore.prototype.events = {
        "click #add_more_mails": 'loadOlderMails'
      };

      MailsListMore.prototype.loadOlderMails = function() {
        var element;
        $("#add_more_mails").addClass("disabled");
        if (this.clickable) {
          this.collection.fetchOlder();
          this.clickable = false;
          element = this;
          return setTimeout(function() {
            element.clickable = true;
            element.render();
            return console.log("retry");
          }, 1000 * 10);
        }
      };

      MailsListMore.prototype.render = function() {
        var template;
        this.clickable = true;
        template = require("./templates/_mail/mails_more");
        $(this.el).html(template({
          "collection": this.collection
        }));
        return this;
      };

      return MailsListMore;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/menu_mailboxes_list": function(exports, require, module) {
  (function() {
    var MenuMailboxListElement,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    MenuMailboxListElement = require("./menu_mailboxes_list_element").MenuMailboxListElement;

    /*
      @file: menu_mailboxes_list.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description: 
        The list of mailboxes in the menu
    */

    exports.MenuMailboxesList = (function(_super) {

      __extends(MenuMailboxesList, _super);

      MenuMailboxesList.prototype.total_inbox = 0;

      function MenuMailboxesList(el, collection) {
        this.el = el;
        this.collection = collection;
        MenuMailboxesList.__super__.constructor.call(this);
        this.collection.viewMenu_mailboxes = this;
        this.collection.on('reset', this.render, this);
        this.collection.on('add', this.render, this);
        this.collection.on('remove', this.render, this);
        this.collection.on('change', this.render, this);
      }

      MenuMailboxesList.prototype.render = function() {
        var _this = this;
        $(this.el).html("");
        this.total_inbox = 0;
        this.collection.each(function(mailbox) {
          var box;
          box = new MenuMailboxListElement(mailbox, _this.collection);
          $(_this.el).append(box.render().el);
          return _this.total_inbox += Number(mailbox.get("new_messages"));
        });
        return this;
      };

      return MenuMailboxesList;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/menu_mailboxes_list_element": function(exports, require, module) {
  
  /*
    @file: menu_mailboxes_list_element.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description: 
      The element of the list of mailboxes in the leftmost column - the menu.
  */

  (function() {
    var __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    exports.MenuMailboxListElement = (function(_super) {

      __extends(MenuMailboxListElement, _super);

      MenuMailboxListElement.prototype.tagName = 'li';

      function MenuMailboxListElement(model, collection) {
        this.model = model;
        this.collection = collection;
        MenuMailboxListElement.__super__.constructor.call(this);
      }

      MenuMailboxListElement.prototype.events = {
        "click a.menu_choose": 'setupMailbox'
      };

      MenuMailboxListElement.prototype.setupMailbox = function(event) {
        this.model.set("checked", !this.model.get("checked"));
        this.model.save();
        this.collection.updateActiveMailboxes();
        return this.collection.trigger("change_active_mailboxes");
      };

      MenuMailboxListElement.prototype.render = function() {
        var template;
        template = require('./templates/_mailbox/mailbox_menu');
        $(this.el).html(template({
          "model": this.model.toJSON()
        }));
        return this;
      };

      return MenuMailboxListElement;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/message_box": function(exports, require, module) {
  (function() {
    var Mail, Mailbox,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    Mailbox = require("../models/mailbox").Mailbox;

    Mail = require("../models/mail").Mail;

    /*
      @file: message_box.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description: 
        Serves a place to display messages which are meant to be seen by user.
        
        Has a set of preconfigured render methods, used by other views.
    */

    exports.MessageBox = (function(_super) {

      __extends(MessageBox, _super);

      function MessageBox(el, mailboxes, mails) {
        this.el = el;
        this.mailboxes = mailboxes;
        this.mails = mails;
        MessageBox.__super__.constructor.call(this);
      }

      MessageBox.prototype.initialize = function() {};

      MessageBox.prototype.addOne = function(mail) {
        var box;
        box = new MailboxesListElement(mail, mail.collection);
        return $(this.el).append(box.render().el);
      };

      MessageBox.prototype.render = function() {
        var template;
        template = require('./templates/_message/normal');
        $(this.el).html(template());
        return this;
      };

      MessageBox.prototype.renderMessageSentSuccess = function() {
        var template;
        template = require('./templates/_message/message_sent');
        $(this.el).html(template());
        return this;
      };

      MessageBox.prototype.renderMessageSentError = function() {
        var template;
        template = require('./templates/_message/message_error');
        $(this.el).html(template());
        return this;
      };

      MessageBox.prototype.renderMailboxNewSuccess = function() {
        var template;
        template = require('./templates/_message/mailbox_new');
        $(this.el).html(template());
        return this;
      };

      MessageBox.prototype.renderMailboxUpdateSuccess = function() {
        var template;
        template = require('./templates/_message/mailbox_update');
        $(this.el).html(template());
        return this;
      };

      return MessageBox;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/templates/_attachment/attachment_element": function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<i');
  buf.push(attrs({ "class": ('icon-file') }));
  buf.push('></i><a');
  buf.push(attrs({ 'href':("getattachment/" + attachment.get("id")), 'target':("_blank") }));
  buf.push('>' + escape((interp = attachment.get("fileName")) == null ? '' : interp) + '</a>');
  }
  return buf.join("");
  };
}});

window.require.define({"views/templates/_layouts/layout_compose_mail": function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div');
  buf.push(attrs({ "class": ('row-fluid') }));
  buf.push('><div');
  buf.push(attrs({ 'id':('compose_mail_container'), "class": ('span12') }));
  buf.push('></div></div>');
  }
  return buf.join("");
  };
}});

window.require.define({"views/templates/_layouts/layout_mailboxes": function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div');
  buf.push(attrs({ "class": ('row-fluid') }));
  buf.push('><div');
  buf.push(attrs({ 'id':('mail_list_container'), "class": ('span12') }));
  buf.push('></div></div><div');
  buf.push(attrs({ "class": ('row-fluid') }));
  buf.push('><div');
  buf.push(attrs({ 'id':('add_mail_button_container'), "class": ('span12') }));
  buf.push('></div></div>');
  }
  return buf.join("");
  };
}});

window.require.define({"views/templates/_layouts/layout_mails": function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div');
  buf.push(attrs({ "class": ('row-fluid') }));
  buf.push('><div');
  buf.push(attrs({ 'id':('column_mails_list'), "class": ('column') + ' ' + ('span4') }));
  buf.push('></div><div');
  buf.push(attrs({ 'id':('column_mail'), "class": ('column') + ' ' + ('span8') }));
  buf.push('></div></div>');
  }
  return buf.join("");
  };
}});

window.require.define({"views/templates/_mail/mail_answer": function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<form');
  buf.push(attrs({ "class": ('well') }));
  buf.push('><fieldset><div');
  buf.push(attrs({ 'id':('mail_basic'), "class": ('control-group') }));
  buf.push('><p>');
  if ( mailtosend.get("mode") == "answer")
  {
  buf.push('Answering to ' + escape((interp = model.from()) == null ? '' : interp) + ' ...\n');
  }
  else if ( mailtosend.get("mode") == "answer_all")
  {
  buf.push('Answering to all ' + escape((interp = model.fromAndCc()) == null ? '' : interp) + ' ...\n');
  }
  else
  {
  buf.push('Forwarding ...\n');
  }
  buf.push('<a');
  buf.push(attrs({ 'id':('mail_detailed_view_button'), "class": ('btn-mini') + ' ' + ('btn-primary') }));
  buf.push('>show&nbsp;details</a></p></div><div');
  buf.push(attrs({ 'id':('mail_to'), "class": ('control-group') }));
  buf.push('><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><div');
  buf.push(attrs({ "class": ('input-prepend') }));
  buf.push('><span');
  buf.push(attrs({ "class": ('add-on') }));
  buf.push('>To&nbsp;</span><input');
  buf.push(attrs({ 'id':("to"), 'type':("text"), 'value':(model.toResponse(mailtosend.get("mode"))), "class": ('content') + ' ' + ('span6') + ' ' + ('input-xlarge') }));
  buf.push('/></div></div></div><div');
  buf.push(attrs({ 'id':('mail_advanced'), "class": ('control-group') }));
  buf.push('><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><div');
  buf.push(attrs({ "class": ('input-prepend') }));
  buf.push('><span');
  buf.push(attrs({ "class": ('add-on') }));
  buf.push('>Cc&nbsp;</span><input');
  buf.push(attrs({ 'id':("cc"), 'type':("text"), 'value':(model.ccResponse(mailtosend.get("mode"))), "class": ('content') + ' ' + ('span6') + ' ' + ('input-xlarge') }));
  buf.push('/></div></div><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><div');
  buf.push(attrs({ "class": ('input-prepend') }));
  buf.push('><span');
  buf.push(attrs({ "class": ('add-on') }));
  buf.push('>Bcc</span><input');
  buf.push(attrs({ 'id':("bcc"), 'type':("text"), 'value':(""), "class": ('content') + ' ' + ('span6') + ' ' + ('input-xlarge') }));
  buf.push('/></div></div><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><div');
  buf.push(attrs({ "class": ('input-prepend') }));
  buf.push('><span');
  buf.push(attrs({ "class": ('add-on') }));
  buf.push('>Subject</span><input');
  buf.push(attrs({ 'id':("subject"), 'type':("text"), 'value':(model.subjectResponse(mailtosend.get("mode"))), "class": ('content') + ' ' + ('span9') + ' ' + ('input-xlarge') }));
  buf.push('/></div></div></div><div');
  buf.push(attrs({ "class": ('control-group') }));
  buf.push('><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><div');
  buf.push(attrs({ 'id':('wysihtml5-toolbar'), 'style':('display: none;') }));
  buf.push('><div');
  buf.push(attrs({ "class": ('btn-toolbar') }));
  buf.push('><div');
  buf.push(attrs({ "class": ('btn-group') }));
  buf.push('><a');
  buf.push(attrs({ 'data-wysihtml5-command':('bold'), "class": ('btn') + ' ' + ('btn-mini') }));
  buf.push('>bold</a><a');
  buf.push(attrs({ 'data-wysihtml5-command':('italic'), "class": ('btn') + ' ' + ('btn-mini') }));
  buf.push('>italic</a><a');
  buf.push(attrs({ 'data-wysihtml5-command':('underline'), "class": ('btn') + ' ' + ('btn-mini') }));
  buf.push('>underline</a></div><div');
  buf.push(attrs({ "class": ('btn-group') }));
  buf.push('><a');
  buf.push(attrs({ 'data-wysihtml5-command':('foreColor'), 'data-wysihtml5-command-value':('red'), "class": ('btn') + ' ' + ('btn-mini') }));
  buf.push('>red</a><a');
  buf.push(attrs({ 'data-wysihtml5-command':('foreColor'), 'data-wysihtml5-command-value':('green'), "class": ('btn') + ' ' + ('btn-mini') }));
  buf.push('>green</a><a');
  buf.push(attrs({ 'data-wysihtml5-command':('foreColor'), 'data-wysihtml5-command-value':('blue'), "class": ('btn') + ' ' + ('btn-mini') }));
  buf.push('>blue</a></div><div');
  buf.push(attrs({ "class": ('btn-group') }));
  buf.push('><a');
  buf.push(attrs({ 'data-wysihtml5-command':('createLink'), "class": ('btn') + ' ' + ('btn-mini') }));
  buf.push('>insert link</a></div><div');
  buf.push(attrs({ 'data-wysihtml5-dialog':('createLink'), 'style':('display: none;border: none;') }));
  buf.push('><form');
  buf.push(attrs({ "class": ('form-inline') }));
  buf.push('><input');
  buf.push(attrs({ 'data-wysihtml5-dialog-field':('href'), 'value':('http://'), "class": ('text') }));
  buf.push('/><a');
  buf.push(attrs({ 'data-wysihtml5-dialog-action':('save'), "class": ('btn') + ' ' + ('btn-mini') }));
  buf.push('>OK</a><a');
  buf.push(attrs({ 'data-wysihtml5-dialog-action':('cancel'), "class": ('btn') + ' ' + ('btn-mini') }));
  buf.push('>Cancel</a></form></div></div></div></div><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><textarea');
  buf.push(attrs({ 'id':("html"), 'rows':(15), 'cols':(80), "class": ('content') + ' ' + ('span10') + ' ' + ('input-xlarge') }));
  buf.push('><blockquote>' + ((interp = model.htmlOrText()) == null ? '' : interp) + '\n</blockquote></textarea><a');
  buf.push(attrs({ 'id':('send_button'), "class": ('btn') + ' ' + ('btn-primary') + ' ' + ('btn-large') }));
  buf.push('>Send !</a></div></div></fieldset></form>');
  }
  return buf.join("");
  };
}});

window.require.define({"views/templates/_mail/mail_big": function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div');
  buf.push(attrs({ "class": ('btn-toolbar') }));
  buf.push('><div');
  buf.push(attrs({ "class": ('btn-group') }));
  buf.push('><a');
  buf.push(attrs({ 'id':('button_answer'), "class": ('btn') + ' ' + ('btn-primary') }));
  buf.push('><i');
  buf.push(attrs({ "class": ('icon-share-alt') }));
  buf.push('></i>Answer\n</a><a');
  buf.push(attrs({ 'id':('button_answer_all'), "class": ('btn') }));
  buf.push('><i');
  buf.push(attrs({ "class": ('icon-share-alt') }));
  buf.push('></i>Answer to all\n</a><a');
  buf.push(attrs({ 'id':('button_forward'), "class": ('btn') }));
  buf.push('><i');
  buf.push(attrs({ "class": ('icon-arrow-up') }));
  buf.push('></i>Forward\n</a></div><div');
  buf.push(attrs({ "class": ('btn-group') }));
  buf.push('><a');
  buf.push(attrs({ 'id':('button_flagged'), "class": ('btn') + ' ' + ('btn-warning') }));
  buf.push('><i');
  buf.push(attrs({ "class": ('icon-star') }));
  buf.push('></i>Flag\n</a><a');
  buf.push(attrs({ 'id':('button_unread'), "class": ('btn') }));
  buf.push('>Unread\n</a><a');
  buf.push(attrs({ "class": ('btn') + ' ' + ('disabled') }));
  buf.push('><i');
  buf.push(attrs({ "class": ('icon-ban-circle') }));
  buf.push('></i>Spam\n</a><a');
  buf.push(attrs({ "class": ('btn') + ' ' + ('btn-danger') + ' ' + ('disabled') }));
  buf.push('><i');
  buf.push(attrs({ "class": ('icon-remove') }));
  buf.push('></i>Delete\n</a></div></div><div');
  buf.push(attrs({ "class": ('well') }));
  buf.push('><p>From: ' + escape((interp = model.from()) == null ? '' : interp) + '\n');
  if ( model.get("cc"))
  {
  buf.push('<p>CC:  ' + escape((interp = model.cc()) == null ? '' : interp) + '\n</p>');
  }
  buf.push('</p><p><i');
  buf.push(attrs({ 'style':('color: lightgray;') }));
  buf.push('>sent ' + escape((interp = model.date()) == null ? '' : interp) + '</i><br');
  buf.push(attrs({  }));
  buf.push('/></p><h3>' + escape((interp = model.get("subject")) == null ? '' : interp) + '</h3><br');
  buf.push(attrs({  }));
  buf.push('/>');
  if ( model.hasHtml())
  {
  buf.push('<iframe');
  buf.push(attrs({ 'id':('mail_content_html'), 'id':("mail_content_html"), 'name':("mail_content_html") }));
  buf.push('>' + ((interp = model.html()) == null ? '' : interp) + '\n</iframe>');
  }
  else
  {
  buf.push('<div');
  buf.push(attrs({ 'id':('mail_content_text') }));
  buf.push('>' + ((interp = model.text()) == null ? '' : interp) + '\n</div>');
  }
  buf.push('</div>');
  if ( model.hasAttachments())
  {
  buf.push('<div');
  buf.push(attrs({ 'id':('attachments_list'), "class": ('well') }));
  buf.push('></div>');
  }
  buf.push('<div');
  buf.push(attrs({ "class": ('btn-toolbar') }));
  buf.push('><div');
  buf.push(attrs({ "class": ('btn-group') }));
  buf.push('><a');
  buf.push(attrs({ 'id':('button_answer'), "class": ('btn') + ' ' + ('btn-primary') }));
  buf.push('><i');
  buf.push(attrs({ "class": ('icon-share-alt') }));
  buf.push('></i>Answer\n</a><a');
  buf.push(attrs({ 'id':('button_answer_all'), "class": ('btn') }));
  buf.push('><i');
  buf.push(attrs({ "class": ('icon-share-alt') }));
  buf.push('></i>Answer to all\n</a><a');
  buf.push(attrs({ 'id':('button_forward'), "class": ('btn') }));
  buf.push('><i');
  buf.push(attrs({ "class": ('icon-arrow-up') }));
  buf.push('></i>Forward\n</a></div><div');
  buf.push(attrs({ "class": ('btn-group') }));
  buf.push('><a');
  buf.push(attrs({ 'id':('button_flagged'), "class": ('btn') + ' ' + ('btn-warning') }));
  buf.push('><i');
  buf.push(attrs({ "class": ('icon-star') }));
  buf.push('></i>Flag\n</a><a');
  buf.push(attrs({ 'id':('button_unread'), "class": ('btn') }));
  buf.push('>Unread\n</a><a');
  buf.push(attrs({ "class": ('btn') + ' ' + ('disabled') }));
  buf.push('><i');
  buf.push(attrs({ "class": ('icon-ban-circle') }));
  buf.push('></i>Spam\n</a><a');
  buf.push(attrs({ "class": ('btn') + ' ' + ('btn-danger') + ' ' + ('disabled') }));
  buf.push('><i');
  buf.push(attrs({ "class": ('icon-remove') }));
  buf.push('></i>Delete\n</a></div></div><div');
  buf.push(attrs({ 'id':('answer_form') }));
  buf.push('></div>');
  }
  return buf.join("");
  };
}});

window.require.define({"views/templates/_mail/mail_compose": function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  if ( models.length > 0)
  {
  buf.push('<form');
  buf.push(attrs({ "class": ('well') }));
  buf.push('><fieldset><div');
  buf.push(attrs({ 'id':('mail_from'), "class": ('control-group') }));
  buf.push('><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><div');
  buf.push(attrs({ "class": ('input-prepend') }));
  buf.push('><span');
  buf.push(attrs({ "class": ('add-on') }));
  buf.push('>From:</span><select');
  buf.push(attrs({ 'id':("mailbox"), "class": ('content') + ' ' + ('input-xlarge') }));
  buf.push('>');
  // iterate models
  (function(){
    if ('number' == typeof models.length) {
      for (var $index = 0, $$l = models.length; $index < $$l; $index++) {
        var mailbox = models[$index];

  buf.push('<option');
  buf.push(attrs({ 'value':(mailbox.get("id")) }));
  buf.push('>' + escape((interp = mailbox.get("name")) == null ? '' : interp) + '</option>');
      }
    } else {
      for (var $index in models) {
        var mailbox = models[$index];

  buf.push('<option');
  buf.push(attrs({ 'value':(mailbox.get("id")) }));
  buf.push('>' + escape((interp = mailbox.get("name")) == null ? '' : interp) + '</option>');
     }
    }
  }).call(this);

  buf.push('</select></div></div></div><div');
  buf.push(attrs({ 'id':('mail_to'), "class": ('control-group') }));
  buf.push('><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><div');
  buf.push(attrs({ "class": ('input-prepend') }));
  buf.push('><span');
  buf.push(attrs({ "class": ('add-on') }));
  buf.push('>To&nbsp;</span><input');
  buf.push(attrs({ 'id':("to"), 'type':("text"), "class": ('content') + ' ' + ('span6') + ' ' + ('input-xlarge') }));
  buf.push('/></div></div></div><div');
  buf.push(attrs({ 'id':('mail_advanced'), "class": ('control-group') }));
  buf.push('><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><div');
  buf.push(attrs({ "class": ('input-prepend') }));
  buf.push('><span');
  buf.push(attrs({ "class": ('add-on') }));
  buf.push('>Cc&nbsp;</span><input');
  buf.push(attrs({ 'id':("cc"), 'type':("text"), "class": ('content') + ' ' + ('span6') + ' ' + ('input-xlarge') }));
  buf.push('/></div></div><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><div');
  buf.push(attrs({ "class": ('input-prepend') }));
  buf.push('><span');
  buf.push(attrs({ "class": ('add-on') }));
  buf.push('>Bcc</span><input');
  buf.push(attrs({ 'id':("bcc"), 'type':("text"), "class": ('content') + ' ' + ('span6') + ' ' + ('input-xlarge') }));
  buf.push('/></div></div><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><div');
  buf.push(attrs({ "class": ('input-prepend') }));
  buf.push('><span');
  buf.push(attrs({ "class": ('add-on') }));
  buf.push('>Subject</span><input');
  buf.push(attrs({ 'id':("subject"), 'type':("text"), "class": ('content') + ' ' + ('span9') + ' ' + ('input-xlarge') }));
  buf.push('/></div></div></div><div');
  buf.push(attrs({ "class": ('control-group') }));
  buf.push('><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><div');
  buf.push(attrs({ 'id':('wysihtml5-toolbar'), 'style':('display: none;') }));
  buf.push('><div');
  buf.push(attrs({ "class": ('btn-toolbar') }));
  buf.push('><div');
  buf.push(attrs({ "class": ('btn-group') }));
  buf.push('><a');
  buf.push(attrs({ 'data-wysihtml5-command':('bold'), "class": ('btn') + ' ' + ('btn-mini') }));
  buf.push('>bold</a><a');
  buf.push(attrs({ 'data-wysihtml5-command':('italic'), "class": ('btn') + ' ' + ('btn-mini') }));
  buf.push('>italic</a><a');
  buf.push(attrs({ 'data-wysihtml5-command':('underline'), "class": ('btn') + ' ' + ('btn-mini') }));
  buf.push('>underline</a></div><div');
  buf.push(attrs({ "class": ('btn-group') }));
  buf.push('><a');
  buf.push(attrs({ 'data-wysihtml5-command':('foreColor'), 'data-wysihtml5-command-value':('red'), "class": ('btn') + ' ' + ('btn-mini') }));
  buf.push('>red</a><a');
  buf.push(attrs({ 'data-wysihtml5-command':('foreColor'), 'data-wysihtml5-command-value':('green'), "class": ('btn') + ' ' + ('btn-mini') }));
  buf.push('>green</a><a');
  buf.push(attrs({ 'data-wysihtml5-command':('foreColor'), 'data-wysihtml5-command-value':('blue'), "class": ('btn') + ' ' + ('btn-mini') }));
  buf.push('>blue</a></div><div');
  buf.push(attrs({ "class": ('btn-group') }));
  buf.push('><a');
  buf.push(attrs({ 'data-wysihtml5-command':('createLink'), "class": ('btn') + ' ' + ('btn-mini') }));
  buf.push('>insert link</a></div><div');
  buf.push(attrs({ 'data-wysihtml5-dialog':('createLink'), 'style':('display: none;border: none;') }));
  buf.push('><form');
  buf.push(attrs({ "class": ('form-inline') }));
  buf.push('><input');
  buf.push(attrs({ 'data-wysihtml5-dialog-field':('href'), 'value':('http://'), "class": ('text') }));
  buf.push('/><a');
  buf.push(attrs({ 'data-wysihtml5-dialog-action':('save'), "class": ('btn') + ' ' + ('btn-mini') }));
  buf.push('>OK</a><a');
  buf.push(attrs({ 'data-wysihtml5-dialog-action':('cancel'), "class": ('btn') + ' ' + ('btn-mini') }));
  buf.push('>Cancel</a></form></div></div></div></div><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><textarea');
  buf.push(attrs({ 'id':("html"), 'rows':(15), 'cols':(80), "class": ('content') + ' ' + ('span10') + ' ' + ('input-xlarge') }));
  buf.push('></textarea><a');
  buf.push(attrs({ 'id':('send_button'), "class": ('btn') + ' ' + ('btn-primary') + ' ' + ('btn-large') }));
  buf.push('>Send !</a></div></div></fieldset></form>');
  }
  else
  {
  buf.push('<div');
  buf.push(attrs({ "class": ('well') }));
  buf.push('><p><strong>Hey !</strong></p><p><Before>You\'ll be able to send mail, You need to configure a mailbox.</Before></p><P>It\'s easy - just click \n<a');
  buf.push(attrs({ 'href':("#config-mailboxes") }));
  buf.push('>add/modify </a>from the menu.\n</P></div>');
  }
  }
  return buf.join("");
  };
}});

window.require.define({"views/templates/_mail/mail_list": function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  if ( visible)
  {
  buf.push('<td');
  buf.push(attrs({ 'style':('width: 5px; padding: 0; background-color: ' + model.getColor() + ';') }));
  buf.push('></td>');
  if ( active)
  {
  buf.push('<td');
  buf.push(attrs({ 'style':('background-color: lightgray; overflow: hidden;') }));
  buf.push('><p>');
  if ( model.isUnread())
  {
  buf.push('<strong>' + escape((interp = model.fromShort()) == null ? '' : interp) + '</strong>');
  }
  else
  {
  buf.push('' + escape((interp = model.fromShort()) == null ? '' : interp) + '\n');
  }
  if ( model.hasAttachments())
  {
  buf.push('<i');
  buf.push(attrs({ "class": ('icon-file') }));
  buf.push('></i>');
  }
  if ( model.isFlagged())
  {
  buf.push('<i');
  buf.push(attrs({ "class": ('icon-star') }));
  buf.push('></i>');
  }
  buf.push('<br');
  buf.push(attrs({  }));
  buf.push('/><i');
  buf.push(attrs({ 'style':('color: black;') }));
  buf.push('>' + escape((interp = model.date()) == null ? '' : interp) + '</i>');
  if ( model.isUnread())
  {
  buf.push('<p><strong>' + escape((interp = model.get("subject")) == null ? '' : interp) + '</strong></p>');
  }
  else
  {
  buf.push('<p>' + escape((interp = model.get("subject")) == null ? '' : interp) + '</p>');
  }
  buf.push('</p></td>');
  }
  else
  {
  buf.push('<td><p>');
  if ( model.isUnread())
  {
  buf.push('<strong>' + escape((interp = model.fromShort()) == null ? '' : interp) + '</strong>');
  }
  else
  {
  buf.push('' + escape((interp = model.fromShort()) == null ? '' : interp) + '\n');
  }
  if ( model.hasAttachments())
  {
  buf.push('<i');
  buf.push(attrs({ "class": ('icon-file') }));
  buf.push('></i>');
  }
  if ( model.isFlagged())
  {
  buf.push('<i');
  buf.push(attrs({ "class": ('icon-star') }));
  buf.push('></i>');
  }
  buf.push('<br');
  buf.push(attrs({  }));
  buf.push('/><i');
  buf.push(attrs({ 'style':('color: gray;') }));
  buf.push('>' + escape((interp = model.date()) == null ? '' : interp) + '</i>');
  if ( model.isUnread())
  {
  buf.push('<p><strong>' + escape((interp = model.get("subject")) == null ? '' : interp) + '</strong></p>');
  }
  else
  {
  buf.push('<p>' + escape((interp = model.get("subject")) == null ? '' : interp) + '</p>');
  }
  buf.push('</p></td>');
  }
  }
  }
  return buf.join("");
  };
}});

window.require.define({"views/templates/_mail/mail_sent": function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<p');
  buf.push(attrs({ "class": ('well') }));
  buf.push('><strong>Mail sent !</strong></p>');
  }
  return buf.join("");
  };
}});

window.require.define({"views/templates/_mail/mails": function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<table');
  buf.push(attrs({ "class": ('table') + ' ' + ('table-striped') }));
  buf.push('><tbody');
  buf.push(attrs({ 'id':('mails_list_container') }));
  buf.push('></tbody></table><div');
  buf.push(attrs({ 'id':('button_load_more_mails') }));
  buf.push('></div>');
  }
  return buf.join("");
  };
}});

window.require.define({"views/templates/_mail/mails_more": function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  if ( collection.length == 0)
  {
  buf.push('<div');
  buf.push(attrs({ "class": ('well') }));
  buf.push('><h3>Hey !\n</h3><p>It looks like there are no mails to show.\n</p><p>If you\'re here for the first time, just click \n<a');
  buf.push(attrs({ 'href':("#config-mailboxes") }));
  buf.push('>add/modify </a>from the menu.\n</p><p>If You just did it, and still see no messages, you may need to wait for us to download them for you.\nEnjoy  :)\n</p></div>');
  }
  buf.push('<div');
  buf.push(attrs({ 'style':("margin-bottom: 50px; margin-top: 50px;"), "class": ('btn-group') + ' ' + ('center') }));
  buf.push('><a');
  buf.push(attrs({ 'id':('add_more_mails'), "class": ('btn') + ' ' + ('btn-primary') + ' ' + ('btn-large') }));
  buf.push('><i');
  buf.push(attrs({ "class": ('icon-plus') }));
  buf.push('></i> Load up to ' + escape((interp = collection.mailsAtOnce) == null ? '' : interp) + ' messages more\n</a></div><p><i>Showing ' + escape((interp = collection.mailsShown) == null ? '' : interp) + ' of ' + escape((interp = collection.length) == null ? '' : interp) + ' messages downloaded</i></p>');
  }
  return buf.join("");
  };
}});

window.require.define({"views/templates/_mailbox/mailbox": function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<h3>' + escape((interp = model.get('name')) == null ? '' : interp) + '</h3><p><i>"' + escape((interp = model.get('SMTP_send_as')) == null ? '' : interp) + '" </i><i>last check at ' + escape((interp = model.IMAPLastFetchedDate()) == null ? '' : interp) + ' </i></p>');
  if ( model.get("status"))
  {
  buf.push('<p><i>status: ' + escape((interp = model.get('status')) == null ? '' : interp) + '</i></p>');
  }
  buf.push('<div');
  buf.push(attrs({ "class": ('btn-group') }));
  buf.push('><a');
  buf.push(attrs({ "class": ('fetch_mails') + ' ' + ('btn') }));
  buf.push('>Check for new mail</a><a');
  buf.push(attrs({ "class": ('fetch_mailbox') + ' ' + ('btn') }));
  buf.push('>Verify status</a><a');
  buf.push(attrs({ "class": ('edit_mailbox') + ' ' + ('btn') }));
  buf.push('>Edit</a><a');
  buf.push(attrs({ "class": ('delete_mailbox') + ' ' + ('btn') + ' ' + ('btn-danger') }));
  buf.push('>Delete</a></div>');
  }
  return buf.join("");
  };
}});

window.require.define({"views/templates/_mailbox/mailbox_edit": function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<from');
  buf.push(attrs({ "class": ('form-horizontal') }));
  buf.push('><fieldset><legend>Access data</legend><div');
  buf.push(attrs({ "class": ('control-group') }));
  buf.push('><label');
  buf.push(attrs({ 'for':("name"), "class": ('control-label') }));
  buf.push('>Title</label><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><input');
  buf.push(attrs({ 'id':("name"), 'type':("text"), 'value':(model.get("name")), "class": ('content') + ' ' + ('input-xlarge') }));
  buf.push('/><p');
  buf.push(attrs({ "class": ('help-block') }));
  buf.push('>Name your mailbox to identify it easily.</p></div></div><div');
  buf.push(attrs({ "class": ('control-group') }));
  buf.push('><label');
  buf.push(attrs({ 'for':("SMTP_send_as"), "class": ('control-label') }));
  buf.push('>Your address</label><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><input');
  buf.push(attrs({ 'id':("SMTP_send_as"), 'type':("text"), 'value':(model.get("SMTP_send_as")), "class": ('content') + ' ' + ('input-xlarge') }));
  buf.push('/><p');
  buf.push(attrs({ "class": ('help-block') }));
  buf.push('>This adress will be visible to people to whom you send mail.</p><p');
  buf.push(attrs({ "class": ('help-block') }));
  buf.push('>Like "johny@mnemonic.com" or "Mickey Mouse <mickey@domain.com>".</p></div></div><div');
  buf.push(attrs({ "class": ('control-group') }));
  buf.push('><label');
  buf.push(attrs({ 'for':("login"), "class": ('control-label') }));
  buf.push('>Your login</label><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><input');
  buf.push(attrs({ 'id':("login"), 'type':("text"), 'value':(model.get("login")), "class": ('content') + ' ' + ('input-xlarge') }));
  buf.push('/></div></div><div');
  buf.push(attrs({ "class": ('control-group') }));
  buf.push('><label');
  buf.push(attrs({ 'for':("pass"), "class": ('control-label') }));
  buf.push('>Your password</label><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><input');
  buf.push(attrs({ 'id':("pass"), 'type':("password"), 'value':(model.get("pass")), "class": ('content') + ' ' + ('input-xlarge') }));
  buf.push('/><p');
  buf.push(attrs({ "class": ('help-block') }));
  buf.push('>Login and password you use for this mailbox. It\'s stored safely, don\'t worry.</p></div></div><div');
  buf.push(attrs({ "class": ('control-group') }));
  buf.push('><label');
  buf.push(attrs({ 'for':("pass"), "class": ('control-label') }));
  buf.push('>Rainbows and unicorns</label><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><select');
  buf.push(attrs({ 'id':("color"), 'value':(model.get("color")), "class": ('content') + ' ' + ('input-xlarge') }));
  buf.push('><option');
  buf.push(attrs({ 'value':("orange") }));
  buf.push('>orange</option><option');
  buf.push(attrs({ 'value':("blue") }));
  buf.push('>blue</option><option');
  buf.push(attrs({ 'value':("red") }));
  buf.push('>red</option><option');
  buf.push(attrs({ 'value':("green") }));
  buf.push('>green</option><option');
  buf.push(attrs({ 'value':("gold") }));
  buf.push('>gold</option><option');
  buf.push(attrs({ 'value':("purple") }));
  buf.push('>purple</option><option');
  buf.push(attrs({ 'value':("pink") }));
  buf.push('>pink</option><option');
  buf.push(attrs({ 'value':("black") }));
  buf.push('>black</option><option');
  buf.push(attrs({ 'value':("brown") }));
  buf.push('>brown</option></select><p');
  buf.push(attrs({ "class": ('help-block') }));
  buf.push('>The color to mark mails from this inbox. Enjoy!</p></div></div></fieldset><fieldset><legend>Server data</legend><div');
  buf.push(attrs({ "class": ('control-group') }));
  buf.push('><label');
  buf.push(attrs({ 'for':("SMTP_server"), "class": ('control-label') }));
  buf.push('>SMTP host</label><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><input');
  buf.push(attrs({ 'id':("SMTP_server"), 'type':("text"), 'value':(model.get("SMTP_server")), "class": ('content') + ' ' + ('input-xlarge') }));
  buf.push('/><p');
  buf.push(attrs({ "class": ('help-block') }));
  buf.push('>The address of your server. Like smtp.gmail.com</p></div></div><div');
  buf.push(attrs({ "class": ('control-group') }));
  buf.push('><label');
  buf.push(attrs({ 'for':("SMTP_ssl"), "class": ('control-label') }));
  buf.push('>SMTP ssl</label><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><input');
  buf.push(attrs({ 'id':("SMTP_ssl"), 'type':("text"), 'value':(model.get("SMTP_ssl").toString()), "class": ('content') + ' ' + ('input-xlarge') }));
  buf.push('/><p');
  buf.push(attrs({ "class": ('help-block') }));
  buf.push('>Everybody wants it, but some servers may not have it. Leave it "true" :)</p></div></div><div');
  buf.push(attrs({ "class": ('control-group') }));
  buf.push('><label');
  buf.push(attrs({ 'for':("IMAP_server"), "class": ('control-label') }));
  buf.push('>IMAP host</label><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><input');
  buf.push(attrs({ 'id':("IMAP_server"), 'type':("text"), 'value':(model.get("IMAP_server")), "class": ('content') + ' ' + ('input-xlarge') }));
  buf.push('/><p');
  buf.push(attrs({ "class": ('help-block') }));
  buf.push('>The inbound server address. Say imap.gmail.com ..</p></div></div><div');
  buf.push(attrs({ "class": ('control-group') }));
  buf.push('><label');
  buf.push(attrs({ 'for':("IMAP_port"), "class": ('control-label') }));
  buf.push('>IMAP port</label><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><input');
  buf.push(attrs({ 'id':("IMAP_port"), 'type':("text"), 'value':(model.get("IMAP_port")), "class": ('content') + ' ' + ('input-xlarge') }));
  buf.push('/><p');
  buf.push(attrs({ "class": ('help-block') }));
  buf.push('>Usually 993.</p></div></div><div');
  buf.push(attrs({ "class": ('control-group') }));
  buf.push('><label');
  buf.push(attrs({ 'for':("IMAP_secure"), "class": ('control-label') }));
  buf.push('>IMAP secure</label><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><input');
  buf.push(attrs({ 'id':("IMAP_secure"), 'type':("text"), 'value':(model.get("IMAP_secure").toString()), "class": ('content') + ' ' + ('input-xlarge') }));
  buf.push('/><p');
  buf.push(attrs({ "class": ('help-block') }));
  buf.push('>Everybody wants it, but some servers may not have it. Leave it "true" :)</p></div></div></fieldset><div');
  buf.push(attrs({ "class": ('form-actions') }));
  buf.push('><input');
  buf.push(attrs({ 'type':('submit'), 'value':("Save"), "class": ('save_mailbox') + ' ' + ('isEdit') + ' ' + ('btn') + ' ' + ('btn-success') }));
  buf.push('/><a');
  buf.push(attrs({ "class": ('cancel_edit_mailbox') + ' ' + ('isEdit') + ' ' + ('btn') + ' ' + ('btn-warning') }));
  buf.push('>Cancel</a></div></from>');
  }
  return buf.join("");
  };
}});

window.require.define({"views/templates/_mailbox/mailbox_menu": function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<a');
  buf.push(attrs({ 'style':("border-left: 3px solid " + (model.color) + "; padding-left: 5px;"), "class": ('menu_choose') + ' ' + ('change_mailboxes_list') }));
  buf.push('>');
  if ( model.checked == true)
  {
  buf.push('<input');
  buf.push(attrs({ 'type':('checkbox'), 'checked':("checked"), "class": ('change_mailboxes_list') }));
  buf.push('/>');
  }
  else
  {
  buf.push('<input');
  buf.push(attrs({ 'type':('checkbox'), "class": ('change_mailboxes_list') }));
  buf.push('/>');
  }
  buf.push(' ' + escape((interp = model.name) == null ? '' : interp) + '\n');
  if ( model.new_messages > 0)
  {
  buf.push('<span');
  buf.push(attrs({ "class": ('badge') + ' ' + ('badge-warning') }));
  buf.push('>' + escape((interp = model.new_messages) == null ? '' : interp) + '</span>');
  }
  buf.push('</a>');
  }
  return buf.join("");
  };
}});

window.require.define({"views/templates/_mailbox/mailbox_new": function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<form');
  buf.push(attrs({ "class": ('well') }));
  buf.push('><a');
  buf.push(attrs({ 'id':('add_mailbox'), "class": ('btn') }));
  buf.push('>Add a new mailbox</a></form>');
  }
  return buf.join("");
  };
}});

window.require.define({"views/templates/_message/mailbox_new": function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div');
  buf.push(attrs({ "class": ('alert') + ' ' + ('alert-success') }));
  buf.push('><button');
  buf.push(attrs({ 'type':("button"), 'data-dismiss':("alert"), "class": ('close') }));
  buf.push('>x</button><strong>Success !\n</strong><p>Your brand new mailbox has been saved. Give us now some time to import Your mail.\n</p></div>');
  }
  return buf.join("");
  };
}});

window.require.define({"views/templates/_message/mailbox_update": function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div');
  buf.push(attrs({ "class": ('alert') + ' ' + ('alert-success') }));
  buf.push('><button');
  buf.push(attrs({ 'type':("button"), 'data-dismiss':("alert"), "class": ('close') }));
  buf.push('>x</button><strong>Success !\n</strong><p>Changes to your mailbox have been saved.\n</p></div>');
  }
  return buf.join("");
  };
}});

window.require.define({"views/templates/_message/message_error": function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div');
  buf.push(attrs({ "class": ('alert') + ' ' + ('alert-error') }));
  buf.push('><button');
  buf.push(attrs({ 'type':("button"), 'data-dismiss':("alert"), "class": ('close') }));
  buf.push('>x</button><strong>Error !\n</strong><p>Your message could not be sent!\n</p><p>Please verify Your mailbox settings!\n</p></div>');
  }
  return buf.join("");
  };
}});

window.require.define({"views/templates/_message/message_sent": function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div');
  buf.push(attrs({ "class": ('alert') + ' ' + ('alert-success') }));
  buf.push('><button');
  buf.push(attrs({ 'type':("button"), 'data-dismiss':("alert"), "class": ('close') }));
  buf.push('>x</button><strong>Success !\n</strong><p>Your message has been sent successfully !\n</p></div>');
  }
  return buf.join("");
  };
}});

window.require.define({"views/templates/_message/normal": function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<p');
  buf.push(attrs({ "class": ('well') }));
  buf.push('>Fetching new mail ...\n</p>');
  }
  return buf.join("");
  };
}});

window.require.define({"views/templates/app": function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div');
  buf.push(attrs({ 'id':('message_box') }));
  buf.push('></div><div');
  buf.push(attrs({ "class": ('container-fluid') }));
  buf.push('><div');
  buf.push(attrs({ "class": ('row-fluid') }));
  buf.push('><div');
  buf.push(attrs({ 'id':('sidebar'), "class": ('span2') }));
  buf.push('><div');
  buf.push(attrs({ 'id':('menu_container'), "class": ('well') + ' ' + ('sidebar-nav') }));
  buf.push('></div></div><div');
  buf.push(attrs({ 'id':('content'), "class": ('span10') }));
  buf.push('></div></div></div>');
  }
  return buf.join("");
  };
}});

window.require.define({"views/templates/menu": function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<ul');
  buf.push(attrs({ "class": ('nav') + ' ' + ('nav-list') }));
  buf.push('><li');
  buf.push(attrs({ "class": ('nav-header') }));
  buf.push('>All your mail</li><li');
  buf.push(attrs({ 'id':('newmailbutton'), "class": ('menu_option') }));
  buf.push('><a');
  buf.push(attrs({ 'href':('#new-mail') }));
  buf.push('>Compose a new mail\n</a></li><li');
  buf.push(attrs({ 'id':('inboxbutton'), "class": ('menu_option') }));
  buf.push('><a');
  buf.push(attrs({ 'href':('#') }));
  buf.push('>Inbox \n</a></li><li');
  buf.push(attrs({ "class": ('divider') }));
  buf.push('></li><li');
  buf.push(attrs({ "class": ('nav-header') }));
  buf.push('>Mailboxes </li></ul><ul');
  buf.push(attrs({ 'id':('menu_mailboxes'), "class": ('nav') + ' ' + ('nav-list') }));
  buf.push('></ul><ul');
  buf.push(attrs({ "class": ('nav') + ' ' + ('nav-list') }));
  buf.push('><li');
  buf.push(attrs({ 'id':('mailboxesbutton') }));
  buf.push('><a');
  buf.push(attrs({ 'href':('#config-mailboxes') }));
  buf.push('>add/modify\n</a></li></ul>');
  }
  return buf.join("");
  };
}});


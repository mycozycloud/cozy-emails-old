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

window.require.define({"collections/mailboxes": function(exports, require, module) {
  (function() {
    var Mailbox,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    Mailbox = require("../models/mailbox").Mailbox;

    /*
    
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
        this.on("add", this.addView, this);
        return this.on("change", this.updateActiveMailboxes, this);
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
        return this.each(function(mb) {
          if (mb.get("checked")) return _this.activeMailboxes.push(mb.get("id"));
        });
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

      MailsCollection.prototype.mailsAtOnce = 100;

      MailsCollection.prototype.comparator = function(a, b) {
        if (a.get("date") > b.get("date")) {
          return -1;
        } else if (a.get("date") === b.get("date")) {
          return 0;
        } else {
          return 1;
        }
      };

      MailsCollection.prototype.initialize = function() {
        this.on("change_active_mail", this.navigateMail, this);
        this.on("add", this.treatAdd, this);
        return setInterval(this.fetchNew, 0.5 * 60 * 1000);
      };

      MailsCollection.prototype.treatAdd = function(model) {
        var box;
        if (new Date(model.get("createdAt")).valueOf() < this.timestampOld) {
          this.timestampOld = new Date(model.get("createdAt")).valueOf();
        }
        if (new Date(model.get("createdAt")).valueOf() > this.timestampNew) {
          this.timestampNew = new Date(model.get("createdAt")).valueOf();
          if (model.is_unread()) {
            box = window.app.mailboxes.get(model.get("mailbox"));
            return box != null ? box.set("new_messages", (parseInt(box != null ? box.get("new_messages") : void 0)) + 1) : void 0;
          }
        }
      };

      MailsCollection.prototype.navigateMail = function(event) {
        if (this.activeMail != null) {
          return window.app.router.navigate("mail/" + this.activeMail.id);
        } else {
          return console.error("NavigateMail without active mail");
        }
      };

      MailsCollection.prototype.fetchOlder = function() {
        this.url = "mailslist/" + this.timestampOld + "." + this.mailsAtOnce;
        console.log("fetchOlder: " + this.url);
        return this.fetch({
          add: true
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
  (function() {
    var AppView, BrunchApplication, MailboxCollection, MailsCollection, MainRouter,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    BrunchApplication = require('helpers').BrunchApplication;

    MainRouter = require('routers/main_router').MainRouter;

    MailboxCollection = require('collections/mailboxes').MailboxCollection;

    MailsCollection = require('collections/mails').MailsCollection;

    AppView = require('views/app').AppView;

    exports.Application = (function(_super) {

      __extends(Application, _super);

      function Application() {
        Application.__super__.constructor.apply(this, arguments);
      }

      Application.prototype.initialize = function() {
        this.mailboxes = new MailboxCollection;
        this.mails = new MailsCollection;
        this.router = new MainRouter;
        return this.appView = new AppView;
      };

      return Application;

    })(BrunchApplication);

    window.app = new exports.Application;

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
    
      Model which defines the MAIL object.
    */

    exports.Mail = (function(_super) {

      __extends(Mail, _super);

      function Mail() {
        Mail.__super__.constructor.apply(this, arguments);
      }

      Mail.prototype.initialize = function() {
        this.on("destroy", this.removeView, this);
        return this.on("change", this.redrawView, this);
      };

      Mail.prototype.removeView = function() {
        if (this.view != null) return this.view.remove();
      };

      Mail.prototype.redrawView = function() {
        if (this.view != null) return this.view.render();
      };

      /*
            RENDERING
      */

      Mail.prototype.from = function() {
        var obj, out, parsed, _i, _len;
        parsed = JSON.parse(this.get("from"));
        out = "";
        for (_i = 0, _len = parsed.length; _i < _len; _i++) {
          obj = parsed[_i];
          out += obj.name + " <" + obj.address + "> ";
        }
        return out;
      };

      Mail.prototype.from_short = function() {
        var obj, out, parsed, _i, _len;
        parsed = JSON.parse(this.get("from"));
        out = "";
        for (_i = 0, _len = parsed.length; _i < _len; _i++) {
          obj = parsed[_i];
          out += obj.name + " ";
        }
        return out;
      };

      Mail.prototype.cc = function() {
        var obj, out, parsed, _i, _len;
        parsed = JSON.parse(this.get("cc"));
        out = "";
        for (_i = 0, _len = parsed.length; _i < _len; _i++) {
          obj = parsed[_i];
          out += obj.name + " <" + obj.address + "> ";
        }
        return out;
      };

      Mail.prototype.cc_short = function() {
        var obj, out, parsed, _i, _len;
        parsed = JSON.parse(this.get("cc"));
        out = "";
        for (_i = 0, _len = parsed.length; _i < _len; _i++) {
          obj = parsed[_i];
          out += obj.name + " ";
        }
        return out;
      };

      Mail.prototype.date = function() {
        var parsed;
        parsed = new Date(this.get("date"));
        return parsed.toUTCString();
      };

      Mail.prototype.text = function() {
        return this.get("text").replace(/\r\n/g, '\n').replace(/\n/g, '<br />');
      };

      Mail.prototype.is_unread = function() {
        return !(__indexOf.call(JSON.parse(this.get("flags")), "\\Seen") >= 0);
      };

      Mail.prototype.set_read = function(read) {
        var box, flags, flags_prev;
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
        } else {
          flags_prev = flags.length;
          flags = $.grep(flags, function(val) {
            return val !== "\\Seen";
          });
          if (glasgs_prev !== flags.length) {
            box = window.app.mailboxes.get(this.get("mailbox"));
            if (box != null) {
              box.set("new_messages", (parseInt(box != null ? box.get("new_messages") : void 0)) + 1);
            }
          }
        }
        return this.set({
          "flags": JSON.stringify(flags)
        });
      };

      return Mail;

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

      Mailbox.prototype.defaults = {
        'checked': true,
        'config': 0,
        'name': "Mailbox",
        'login': "login",
        'pass': "pass",
        'SMTP_server': "smtp.gmail.com",
        'SMTP_ssl': true,
        'SMTP_send_as': "Adam Smith",
        'IMAP_server': "imap.gmail.com",
        'IMAP_port': 993,
        'IMAP_secure': true
      };

      Mailbox.prototype.initialize = function() {
        this.on("destroy", this.removeView, this);
        return this.on("change", this.redrawView, this);
      };

      Mailbox.prototype.removeView = function() {
        if (this.view != null) return this.view.remove();
      };

      Mailbox.prototype.redrawView = function() {
        if (this.view != null) return this.view.render();
      };

      Mailbox.prototype.IMAP_last_fetched_date = function() {
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

      BaseModel.prototype.render_from = function(from) {
        var obj, out, parsed, _i, _len;
        parsed = JSON.parse(from);
        out = "";
        for (_i = 0, _len = parsed.length; _i < _len; _i++) {
          obj = parsed[_i];
          out += obj.name + " <" + obj.address + "> ";
        }
        return out;
      };

      BaseModel.prototype.render_date = function(date) {
        var parsed;
        parsed = new Date(date);
        return parsed.toUTCString();
      };

      return BaseModel;

    })(Backbone.Model);

  }).call(this);
  
}});

window.require.define({"routers/main_router": function(exports, require, module) {
  
  /*

    Application's router.
  */

  (function() {
    var __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    exports.MainRouter = (function(_super) {

      __extends(MainRouter, _super);

      function MainRouter() {
        MainRouter.__super__.constructor.apply(this, arguments);
      }

      MainRouter.prototype.routes = {
        '': 'home',
        'inbox': 'home',
        'config-mailboxes': 'configMailboxes'
      };

      MainRouter.prototype.initialize = function() {
        return this.route(/^mail\/(.*?)$/, 'mail');
      };

      MainRouter.prototype.home = function() {
        app.appView.render();
        return app.appView.set_layout_mails();
      };

      MainRouter.prototype.configMailboxes = function() {
        app.appView.render();
        return app.appView.set_layout_mailboxes();
      };

      MainRouter.prototype.mail = function(path) {
        app.appView.render();
        app.appView.set_layout_mails();
        if (app.mails.get(path) != null) {
          app.mails.activeMail = app.mails.get(path);
          return app.mails.trigger("change_active_mail");
        } else {
          return app.mails.fetch({
            "success": function() {
              if (app.mails.get(path) != null) {
                app.mails.activeMail = app.mails.get(path);
                return app.mails.trigger("change_active_mail");
              }
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
    var MailboxesList, MailboxesListNew, MailsColumn, MailsElement, MenuMailboxesList,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    MailboxesList = require('../views/mailboxes_list').MailboxesList;

    MailboxesListNew = require('../views/mailboxes_list_new').MailboxesListNew;

    MenuMailboxesList = require('../views/menu_mailboxes_list').MenuMailboxesList;

    MailsColumn = require('../views/mails_column').MailsColumn;

    MailsElement = require('../views/mails_element').MailsElement;

    /*
    
      The application's main view - creates other views, lays things out.
    */

    exports.AppView = (function(_super) {

      __extends(AppView, _super);

      AppView.prototype.id = 'home-view';

      AppView.prototype.el = 'body';

      AppView.prototype.initialize = function() {
        window.app.mailboxes.fetch({
          success: function() {
            window.app.mailboxes.updateActiveMailboxes();
            return window.app.mailboxes.trigger("change_active_mailboxes");
          }
        });
        return window.onresize = this.resize;
      };

      function AppView() {
        AppView.__super__.constructor.call(this);
      }

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
        $("body").height(viewport());
        return $("#content").height(viewport() - 40);
      };

      AppView.prototype.render = function() {
        $(this.el).html(require('./templates/app'));
        this.container_menu = this.$("#menu_container");
        this.container_content = this.$("#content");
        this.set_layout_menu();
        return this;
      };

      AppView.prototype.set_layout_menu = function() {
        this.container_menu.html(require('./templates/menu'));
        window.app.view_menu = new MenuMailboxesList(this.$("#menu_mailboxes"), window.app.mailboxes);
        window.app.view_menu.render();
        return this.resize();
      };

      AppView.prototype.set_layout_mailboxes = function() {
        this.container_content.html(require('./templates/_layouts/layout_mailboxes'));
        window.app.view_mailboxes = new MailboxesList(this.$("#mail_list_container"), window.app.mailboxes);
        window.app.view_mailboxes_new = new MailboxesListNew(this.$("#add_mail_button_container"), window.app.mailboxes);
        window.app.view_mailboxes.render();
        window.app.view_mailboxes_new.render();
        return this.resize();
      };

      AppView.prototype.set_layout_mails = function() {
        this.container_content.html(require('./templates/_layouts/layout_mails'));
        window.app.view_mails_list = new MailsColumn(this.$("#column_mails_list"), window.app.mails);
        window.app.view_mail = new MailsElement(this.$("#column_mail"), window.app.mails);
        window.app.view_mails_list.render();
        window.app.view_mail.render();
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
        this.collection.on('reset', this.render, this);
        return this.collection.fetch();
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
    
      The element of the list of mailboxes.
      
      mailboxes_list -> mailboxes_list_element
    */

    exports.MailboxesListElement = (function(_super) {

      __extends(MailboxesListElement, _super);

      MailboxesListElement.prototype.className = "mailbox_well well";

      MailboxesListElement.prototype.tagName = "div";

      MailboxesListElement.prototype.isEdit = false;

      MailboxesListElement.prototype.events = {
        "click .edit_mailbox": "buttonEdit",
        "click .cancel_edit_mailbox": "buttonCancel",
        "click .save_mailbox": "buttonSave",
        "click .delete_mailbox": "buttonDelete"
      };

      function MailboxesListElement(model, collection) {
        this.model = model;
        this.collection = collection;
        this.buttonDelete = __bind(this.buttonDelete, this);
        MailboxesListElement.__super__.constructor.call(this);
        this.model.view = this;
      }

      MailboxesListElement.prototype.buttonEdit = function(event) {
        this.model.isEdit = true;
        return this.render();
      };

      MailboxesListElement.prototype.buttonCancel = function(event) {
        this.model.isEdit = false;
        return this.render();
      };

      MailboxesListElement.prototype.buttonSave = function(event) {
        var data, input;
        $(event.target).addClass("disabled").removeClass("buttonSave");
        input = this.$(".content");
        data = {};
        input.each(function(i) {
          return data[input[i].id] = input[i].value;
        });
        this.model.save(data);
        this.collection.trigger("update_menu");
        this.model.isEdit = false;
        return this.render();
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

window.require.define({"views/mails_column": function(exports, require, module) {
  (function() {
    var Mail, MailsList, MailsListMore,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    Mail = require("../models/mail").Mail;

    MailsList = require("../views/mails_list").MailsList;

    MailsListMore = require("../views/mails_list_more").MailsListMore;

    /*
    
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
        this.view_mails_list = new MailsList(this.$("#mails_list_container"), this.collection);
        this.view_mails_list_more = new MailsListMore(this.$("#button_load_more_mails"), this.collection);
        this.view_mails_list.render();
        this.view_mails_list_more.render();
        return this;
      };

      return MailsColumn;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/mails_element": function(exports, require, module) {
  (function() {
    var Mail,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    Mail = require("../models/mail").Mail;

    /*
    
      The mail view. Displays all data & options
    */

    exports.MailsElement = (function(_super) {

      __extends(MailsElement, _super);

      function MailsElement(el, collection) {
        this.el = el;
        this.collection = collection;
        MailsElement.__super__.constructor.call(this);
        this.collection.on("change_active_mail", this.render, this);
      }

      MailsElement.prototype.render = function() {
        var template;
        $(this.el).html("");
        template = require('./templates/_mail/mail_big');
        if (this.collection.activeMail != null) {
          $(this.el).html(template({
            "model": this.collection.activeMail
          }));
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
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
      __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

    Mail = require("../models/mail").Mail;

    MailsListElement = require("./mails_list_element").MailsListElement;

    /*
    
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
        this.collection.on('add', this.addOne, this);
        window.app.mailboxes.on('change_active_mailboxes', this.render, this);
        return this.collection.fetchOlder();
      };

      MailsList.prototype.addOne = function(mail) {
        var box, _ref;
        if (_ref = mail.get("mailbox"), __indexOf.call(window.app.mailboxes.activeMailboxes, _ref) >= 0) {
          mail.mailbox = window.app.mailboxes.get(mail.get("mailbox"));
          box = new MailsListElement(mail, mail.collection);
          return $(this.el).append(box.render().el);
        }
      };

      MailsList.prototype.addNew = function(mail) {
        var box, _ref;
        if (_ref = mail.get("mailbox"), __indexOf.call(window.app.mailboxes.activeMailboxes, _ref) >= 0) {
          mail.mailbox = window.app.mailboxes.get(mail.get("mailbox"));
          box = new MailsListElement(mail, mail.collection);
          return $(this.el).prepend(box.render().el);
        }
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
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    Mail = require("../models/mail").Mail;

    /*
    
      The element on the list of mails. Reacts for events, and stuff.
    */

    exports.MailsListElement = (function(_super) {

      __extends(MailsListElement, _super);

      MailsListElement.prototype.tagName = "tr";

      MailsListElement.prototype.events = {
        "click": "setActiveMail"
      };

      function MailsListElement(model, collection) {
        this.model = model;
        this.collection = collection;
        MailsListElement.__super__.constructor.call(this);
        this.model.view = this;
        this.collection.on("change_active_mail", this.render, this);
      }

      MailsListElement.prototype.setActiveMail = function(event) {
        this.collection.activeMail = this.model;
        this.collection.trigger("change_active_mail");
        return this.collection.activeMail.set_read();
      };

      MailsListElement.prototype.render = function() {
        var template;
        template = require('./templates/_mail/mail_list');
        $(this.el).html(template({
          "model": this.model,
          "active": this.model === this.collection.activeMail
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
    
      The view with the "load more" button.
    */

    exports.MailsListMore = (function(_super) {

      __extends(MailsListMore, _super);

      function MailsListMore(el, collection) {
        this.el = el;
        this.collection = collection;
        MailsListMore.__super__.constructor.call(this);
      }

      MailsListMore.prototype.events = {
        "click #add_more_mails": 'loadOlderMails'
      };

      MailsListMore.prototype.render = function() {
        var template;
        template = require("./templates/_mail/mails_more");
        $(this.el).html(template({
          "collection": this.collection
        }));
        return this;
      };

      MailsListMore.prototype.loadOlderMails = function() {
        return this.collection.fetchOlder();
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
    
      The list of mailboxes in the leftmost column - the menu.
    */

    exports.MenuMailboxesList = (function(_super) {

      __extends(MenuMailboxesList, _super);

      MenuMailboxesList.prototype.total_inbox = 0;

      function MenuMailboxesList(el, collection) {
        this.el = el;
        this.collection = collection;
        MenuMailboxesList.__super__.constructor.call(this);
        this.collection.view_menu_mailboxes = this;
        this.collection.on('reset', this.render, this);
        this.collection.on('add', this.render, this);
        this.collection.on('remove', this.render, this);
        this.collection.on('change', this.render, this);
      }

      MenuMailboxesList.prototype.events = {
        "click .change_mailboxes_list": 'setupMailbox'
      };

      MenuMailboxesList.prototype.setupMailbox = function(event) {
        var id, mb;
        id = event.target.getAttribute("mailbox_id");
        mb = this.collection.get(id);
        mb.set("checked", !mb.get("checked"));
        mb.save();
        this.collection.updateActiveMailboxes();
        this.collection.trigger("change_active_mailboxes");
        return console.log("yaha");
      };

      MenuMailboxesList.prototype.render = function() {
        var _this = this;
        $(this.el).html("");
        this.total_inbox = 0;
        this.collection.each(function(mail) {
          var box;
          box = new MenuMailboxListElement(mail, mail.collection);
          $(_this.el).append(box.render().el);
          return _this.total_inbox += Number(mail.get("new_messages"));
        });
        return this;
      };

      return MenuMailboxesList;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/menu_mailboxes_list_element": function(exports, require, module) {
  
  /*

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

window.require.define({"views/templates/_mail/mail_big": function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div');
  buf.push(attrs({ "class": ('well') }));
  buf.push('><p>From: ' + escape((interp = model.from()) == null ? '' : interp) + '\n<i');
  buf.push(attrs({ 'style':('color: lightgray;') }));
  buf.push('>sent ' + escape((interp = model.date()) == null ? '' : interp) + '</i><br');
  buf.push(attrs({  }));
  buf.push('/>');
  if ( model.get("cc"))
  {
  buf.push('CC:  ' + escape((interp = model.cc()) == null ? '' : interp) + '\n');
  }
  buf.push('</p><h3>' + escape((interp = model.get("subject")) == null ? '' : interp) + '</h3><br');
  buf.push(attrs({  }));
  buf.push('/><div');
  buf.push(attrs({ 'id':('mail_content') }));
  buf.push('>');
  if ( model.get("html"))
  {
  buf.push('' + ((interp = model.get("html")) == null ? '' : interp) + '\n');
  }
  else
  {
  buf.push('' + ((interp = model.text()) == null ? '' : interp) + '\n');
  }
  buf.push('</div></div><div');
  buf.push(attrs({ "class": ('btn-toolbar') }));
  buf.push('><div');
  buf.push(attrs({ "class": ('btn-group') }));
  buf.push('><a');
  buf.push(attrs({ "class": ('btn') + ' ' + ('btn-primary') }));
  buf.push('><i');
  buf.push(attrs({ "class": ('icon-share-alt') }));
  buf.push('></i>Answer\n</a><a');
  buf.push(attrs({ "class": ('btn') }));
  buf.push('><i');
  buf.push(attrs({ "class": ('icon-share-alt') }));
  buf.push('></i>Answer to all\n</a><a');
  buf.push(attrs({ "class": ('btn') }));
  buf.push('><i');
  buf.push(attrs({ "class": ('icon-arrow-up') }));
  buf.push('></i>Forward\n</a></div><div');
  buf.push(attrs({ "class": ('btn-group') }));
  buf.push('><a');
  buf.push(attrs({ "class": ('btn') + ' ' + ('btn-warning') }));
  buf.push('><i');
  buf.push(attrs({ "class": ('icon-star') }));
  buf.push('></i>Important\n</a><a');
  buf.push(attrs({ "class": ('btn') }));
  buf.push('><i');
  buf.push(attrs({ "class": ('icon-ban-circle') }));
  buf.push('></i>Spam\n</a><a');
  buf.push(attrs({ "class": ('btn') + ' ' + ('btn-danger') }));
  buf.push('><i');
  buf.push(attrs({ "class": ('icon-remove') }));
  buf.push('></i>Delete\n</a></div></div>');
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
  if ( active)
  {
  buf.push('<td');
  buf.push(attrs({ 'style':('width: 5px; padding: 0; background-color: ' + (model.mailbox.get("color")) + ';') }));
  buf.push('></td><td');
  buf.push(attrs({ 'style':('background-color: lightgray;') }));
  buf.push('><p>');
  if ( model.is_unread())
  {
  buf.push('<strong>' + escape((interp = model.from_short()) == null ? '' : interp) + '</strong>');
  }
  else
  {
  buf.push('' + escape((interp = model.from_short()) == null ? '' : interp) + '\n');
  }
  buf.push('<br');
  buf.push(attrs({  }));
  buf.push('/><i');
  buf.push(attrs({ 'style':('color: gray;') }));
  buf.push('>' + escape((interp = model.date()) == null ? '' : interp) + '</i>');
  if ( model.is_unread())
  {
  buf.push('<p><strong>' + escape((interp = model.get("subject")) == null ? '' : interp) + '</strong></p>');
  }
  else
  {
  buf.push('<p>' + escape((interp = model.get("subject")) == null ? '' : interp) + '</p>');
  }
  buf.push('</p></td><td');
  buf.push(attrs({ 'style':('background-color: lightgray;') }));
  buf.push('></td>');
  }
  else
  {
  buf.push('<td');
  buf.push(attrs({ 'style':('width: 5px; padding: 0; background-color: ' + (model.mailbox.get("color")) + ';') }));
  buf.push('></td><td><p>');
  if ( model.is_unread())
  {
  buf.push('<strong>' + escape((interp = model.from_short()) == null ? '' : interp) + '</strong>');
  }
  else
  {
  buf.push('' + escape((interp = model.from_short()) == null ? '' : interp) + '\n');
  }
  buf.push('<br');
  buf.push(attrs({  }));
  buf.push('/><i');
  buf.push(attrs({ 'style':('color: lightgray;') }));
  buf.push('>' + escape((interp = model.date()) == null ? '' : interp) + '</i></p>');
  if ( model.is_unread())
  {
  buf.push('<p><strong>' + escape((interp = model.get("subject")) == null ? '' : interp) + '</strong></p>');
  }
  else
  {
  buf.push('<p>' + escape((interp = model.get("subject")) == null ? '' : interp) + '</p>');
  }
  buf.push('</td><td><a');
  buf.push(attrs({ "class": ('btn') + ' ' + ('btn-mini') + ' ' + ('choose_mail_button') }));
  buf.push('><i');
  buf.push(attrs({ "class": ('icon-arrow-right') }));
  buf.push('></i></a></td>');
  }
  }
  return buf.join("");
  };
}});

window.require.define({"views/templates/_mail/mail_list_empty": function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div');
  buf.push(attrs({ "class": ('well') }));
  buf.push('><p><strong>Ups, no mails to show...\n</strong></p><p><a');
  buf.push(attrs({ 'href':("#config-mailboxes") }));
  buf.push('>Perhaps configure a mailbox ?</a></p></div>');
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
  buf.push('<div');
  buf.push(attrs({ "class": ('btn-group') + ' ' + ('pull-left') }));
  buf.push('><a');
  buf.push(attrs({ 'id':('add_more_mails'), "class": ('btn') + ' ' + ('btn-primary') }));
  buf.push('><i');
  buf.push(attrs({ "class": ('icon-plus') }));
  buf.push('></i>Load ' + escape((interp = collection.mailsAtOnce) == null ? '' : interp) + ' messages more\n</a></div>');
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
  buf.push('<p><strong>' + escape((interp = model.get('name')) == null ? '' : interp) + '</strong>: \n<i>"' + escape((interp = model.get('SMTP_send_as')) == null ? '' : interp) + '" </i><i>last check at ' + escape((interp = model.IMAP_last_fetched_date()) == null ? '' : interp) + ' </i><a');
  buf.push(attrs({ "class": ('edit_mailbox') + ' ' + ('isntEdit') + ' ' + ('btn') }));
  buf.push('>Edit</a><a');
  buf.push(attrs({ "class": ('delete_mailbox') + ' ' + ('isntEdit') + ' ' + ('btn') + ' ' + ('btn-danger') }));
  buf.push('>Delete</a>');
  if ( model.get("status"))
  {
  buf.push('<p><i>status: ' + escape((interp = model.get('status')) == null ? '' : interp) + '</i></p>');
  }
  buf.push('</p>');
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
  buf.push('>Your name</label><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><input');
  buf.push(attrs({ 'id':("name"), 'type':("text"), 'value':(model.get("name")), "class": ('content') + ' ' + ('input-xlarge') }));
  buf.push('/><p');
  buf.push(attrs({ "class": ('help-block') }));
  buf.push('>This name will be visible to people to whom you send mail.</p></div></div><div');
  buf.push(attrs({ "class": ('control-group') }));
  buf.push('><label');
  buf.push(attrs({ 'for':("SMTP_send_as"), "class": ('control-label') }));
  buf.push('>Your address</label><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><input');
  buf.push(attrs({ 'id':("SMTP_send_as"), 'type':("text"), 'value':(model.get("SMTP_send_as")), "class": ('content') + ' ' + ('input-xlarge') }));
  buf.push('/><p');
  buf.push(attrs({ "class": ('help-block') }));
  buf.push('>Your mail address associated with this account.</p></div></div><div');
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
  buf.push('>Rainbow nad unicorns</label><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><select');
  buf.push(attrs({ 'id':("color"), 'value':(model.get("color")), "class": ('content') + ' ' + ('input-xlarge') }));
  buf.push('><option');
  buf.push(attrs({ 'value':("orange") }));
  buf.push('>orange</option><option');
  buf.push(attrs({ 'value':("blue") }));
  buf.push('>blue</option><option');
  buf.push(attrs({ 'value':("red") }));
  buf.push('>red</option></select><p');
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
  buf.push(attrs({ 'mailbox_id':(model.id), 'style':("border-left: 3px solid " + (model.color) + "; padding-left: 5px;"), "class": ('change_mailboxes_list') }));
  buf.push('>');
  if ( model.checked == true)
  {
  buf.push('<input');
  buf.push(attrs({ 'type':('checkbox'), 'mailbox_id':(model.id), 'checked':("checked"), "class": ('change_mailboxes_list') }));
  buf.push('/>');
  }
  else
  {
  buf.push('<input');
  buf.push(attrs({ 'type':('checkbox'), 'mailbox_id':(model.id), "class": ('change_mailboxes_list') }));
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

window.require.define({"views/templates/app": function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div');
  buf.push(attrs({ "class": ('container-fluid') }));
  buf.push('><div');
  buf.push(attrs({ "class": ('row-fluid') }));
  buf.push('><div');
  buf.push(attrs({ 'id':('sidebar'), "class": ('span2') }));
  buf.push('><div');
  buf.push(attrs({ 'id':('menu_container'), "class": ('well') + ' ' + ('sidebar-nav') }));
  buf.push('></div></div><div');
  buf.push(attrs({ 'id':('content'), "class": ('span10') }));
  buf.push('></div></div><div');
  buf.push(attrs({ "class": ('row-fluid') }));
  buf.push('><div');
  buf.push(attrs({ "class": ('span12') }));
  buf.push('><footer><p>© CozyCloud 2012</p></footer></div></div></div>');
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
  buf.push(attrs({ "class": ('active') }));
  buf.push('><a');
  buf.push(attrs({ 'href':('#') }));
  buf.push('>Inbox\n</a></li><li');
  buf.push(attrs({ "class": ('divider') }));
  buf.push('></li><li');
  buf.push(attrs({ "class": ('nav-header') }));
  buf.push('>Mailboxes</li></ul><ul');
  buf.push(attrs({ 'id':('menu_mailboxes'), "class": ('nav') + ' ' + ('nav-list') }));
  buf.push('></ul><ul');
  buf.push(attrs({ "class": ('nav') + ' ' + ('nav-list') }));
  buf.push('><li><a');
  buf.push(attrs({ 'href':('#config-mailboxes') }));
  buf.push('>add/modify\n</a></li></ul>');
  }
  return buf.join("");
  };
}});


(function(/*! Brunch !*/) {
  'use strict';

  var globals = typeof window !== 'undefined' ? window : global;
  if (typeof globals.require === 'function') return;

  var modules = {};
  var cache = {};

  var has = function(object, name) {
    return hasOwnProperty.call(object, name);
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
      return require(absolute);
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

    exports.MailboxCollection = (function(_super) {

      __extends(MailboxCollection, _super);

      function MailboxCollection() {
        MailboxCollection.__super__.constructor.apply(this, arguments);
      }

      MailboxCollection.prototype.model = Mailbox;

      MailboxCollection.prototype.url = 'mailboxes/';

      MailboxCollection.prototype.initialize = function() {
        return this.on("add", this.addView, this);
      };

      MailboxCollection.prototype.comparator = function(Mailbox) {
        return Mailbox.get("name");
      };

      MailboxCollection.prototype.addView = function(mail) {
        if (this.view != null) return this.view.addOne(mail);
      };

      MailboxCollection.prototype.setCurrentMailboxes = function() {};

      return MailboxCollection;

    })(Backbone.Collection);

  }).call(this);
  
}});

window.require.define({"collections/mails": function(exports, require, module) {
  (function() {
    var Mail,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    Mail = require("../models/mail").Mail;

    exports.MailsCollection = (function(_super) {

      __extends(MailsCollection, _super);

      function MailsCollection() {
        MailsCollection.__super__.constructor.apply(this, arguments);
      }

      MailsCollection.prototype.model = Mail;

      MailsCollection.prototype.url = 'mails/';

      MailsCollection.prototype.comparator = function(Mail) {
        return Mail.get("date");
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

    AppView = require('views/app_view').AppView;

    MailboxCollection = require('collections/mailboxes').MailboxCollection;

    MailsCollection = require('collections/mails').MailsCollection;

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

window.require.define({"models/config": function(exports, require, module) {
  (function() {
    var BaseModel,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    BaseModel = require("./models").BaseModel;

    exports.Config = (function(_super) {

      __extends(Config, _super);

      function Config() {
        Config.__super__.constructor.apply(this, arguments);
      }

      Config.prototype.defaults = {
        'active_mailboxes': {},
        'active_mail': ""
      };

      return Config;

    })(BaseModel);

  }).call(this);
  
}});

window.require.define({"models/mail": function(exports, require, module) {
  (function() {
    var BaseModel,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    BaseModel = require("./models").BaseModel;

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

    exports.Mailbox = (function(_super) {

      __extends(Mailbox, _super);

      function Mailbox() {
        Mailbox.__super__.constructor.apply(this, arguments);
      }

      Mailbox.prototype.defaults = {
        'new_messages': 1,
        'config': 0,
        'name': "Mailbox",
        'createdAt': "0",
        'SMTP_server': "smtp.gmail.com",
        'SMTP_port': "465",
        'SMTP_login': "login",
        'SMTP_pass': "pass",
        'SMTP_send_as': "You"
      };

      Mailbox.prototype.deleted = false;

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

      return Mailbox;

    })(BaseModel);

  }).call(this);
  
}});

window.require.define({"models/models": function(exports, require, module) {
  (function() {
    var __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    exports.BaseModel = (function(_super) {

      __extends(BaseModel, _super);

      function BaseModel() {
        BaseModel.__super__.constructor.apply(this, arguments);
      }

      BaseModel.prototype.isNew = function() {
        return !(this.id != null);
      };

      return BaseModel;

    })(Backbone.Model);

  }).call(this);
  
}});

window.require.define({"routers/main_router": function(exports, require, module) {
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
        'config-mailboxes': 'configMailboxes'
      };

      MainRouter.prototype.home = function() {
        app.appView.render();
        return app.appView.set_layout_mails();
      };

      MainRouter.prototype.configMailboxes = function() {
        app.appView.render();
        return app.appView.set_layout_mailboxes();
      };

      return MainRouter;

    })(Backbone.Router);

  }).call(this);
  
}});

window.require.define({"views/app_view": function(exports, require, module) {
  (function() {
    var MailColumnView, MailboxesList, MailboxesMenuList, MailboxesNew, MailsColumnList,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    MailboxesList = require('../views/mailboxes_view').MailboxesList;

    MailboxesNew = require('../views/mailboxes_new_view').MailboxesNew;

    MailboxesMenuList = require('../views/mailboxes_menu_view').MailboxesMenuList;

    MailsColumnList = require('../views/mails_column_view').MailsColumnList;

    MailColumnView = require('../views/mail_view').MailColumnView;

    exports.AppView = (function(_super) {

      __extends(AppView, _super);

      AppView.prototype.id = 'home-view';

      AppView.prototype.el = 'body';

      AppView.prototype.initialize = function() {
        return window.app.mailboxes.fetch();
      };

      function AppView() {
        AppView.__super__.constructor.call(this);
      }

      AppView.prototype.render = function() {
        $(this.el).html(require('./templates/app'));
        this.container_menu = this.$("#menu_container");
        this.container_content = this.$("#content");
        this.set_layout_menu();
        return this;
      };

      AppView.prototype.set_layout_menu = function() {
        this.container_menu.html(require('./templates/menu'));
        window.app.view_menu = new MailboxesMenuList(this.$("#menu_mailboxes"), window.app.mailboxes);
        return window.app.view_menu.render();
      };

      AppView.prototype.set_layout_mailboxes = function() {
        this.container_content.html(require('./templates/_layouts/layout_mailboxes'));
        window.app.view_mailboxes = new MailboxesList(this.$("#mail_list_container"), window.app.mailboxes);
        window.app.view_mailboxes_new = new MailboxesNew(this.$("#add_mail_button_container"), window.app.mailboxes);
        window.app.view_mailboxes.render();
        return window.app.view_mailboxes_new.render();
      };

      AppView.prototype.set_layout_mails = function() {
        this.container_content.html(require('./templates/_layouts/layout_mails'));
        window.app.view_mails_list = new MailsColumnList(this.$("#column_mails_list"), window.app.mails);
        window.app.view_mail = new MailColumnView(this.$("#column_mail"), window.app.mails);
        return window.app.view_mails_list.render();
      };

      AppView.prototype.set_layout_cols = function() {
        return this.container_content.html(require('./templates/_mail/mails'));
      };

      return AppView;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/mail_list_view": function(exports, require, module) {
  (function() {
    var Mail,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    Mail = require("../models/mail").Mail;

    exports.MailListView = (function(_super) {

      __extends(MailListView, _super);

      MailListView.prototype.tagName = "tr";

      MailListView.prototype.events = {
        "click .choose_mail_button": "setActiveMail"
      };

      function MailListView(model, collection) {
        this.model = model;
        this.collection = collection;
        MailListView.__super__.constructor.call(this);
        this.model.view = this;
        this.collection.on("change_active_mail", this.render, this);
      }

      MailListView.prototype.setActiveMail = function(event) {
        this.collection.activeMail = this.model;
        return this.collection.trigger("change_active_mail");
      };

      MailListView.prototype.render = function() {
        var template;
        template = require('./templates/_mail/mail_list');
        $(this.el).html(template({
          "model": this.model.toJSON(),
          "active": this.model === this.collection.activeMail
        }));
        return this;
      };

      return MailListView;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/mail_view": function(exports, require, module) {
  (function() {
    var Mail,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    Mail = require("../models/mail").Mail;

    exports.MailColumnView = (function(_super) {

      __extends(MailColumnView, _super);

      function MailColumnView(el, collection) {
        this.el = el;
        this.collection = collection;
        MailColumnView.__super__.constructor.call(this);
        this.collection.on("change_active_mail", this.render, this);
      }

      MailColumnView.prototype.render = function() {
        var template, _ref;
        template = require('./templates/_mail/mail_big');
        console.log(this.collection.activeMail);
        $(this.el).html(template({
          "model": (_ref = this.collection.activeMail) != null ? _ref.toJSON() : void 0
        }));
        return this;
      };

      return MailColumnView;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/mailbox_menu_view": function(exports, require, module) {
  (function() {
    var __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    exports.MailboxMenuView = (function(_super) {

      __extends(MailboxMenuView, _super);

      MailboxMenuView.prototype.tagName = 'li';

      function MailboxMenuView(model, collection) {
        this.model = model;
        this.collection = collection;
        MailboxMenuView.__super__.constructor.call(this);
      }

      MailboxMenuView.prototype.render = function() {
        var template;
        template = require('./templates/_mailbox/mailbox_menu');
        $(this.el).html(template({
          "model": this.model.toJSON()
        }));
        return this;
      };

      return MailboxMenuView;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/mailbox_view": function(exports, require, module) {
  (function() {
    var Mailbox,
      __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    Mailbox = require("../models/mailbox").Mailbox;

    exports.MailboxView = (function(_super) {

      __extends(MailboxView, _super);

      MailboxView.prototype.className = "mailbox_well well";

      MailboxView.prototype.tagName = "div";

      MailboxView.prototype.isEdit = false;

      MailboxView.prototype.events = {
        "click .edit_mailbox": "buttonEdit",
        "click .cancel_edit_mailbox": "buttonCancel",
        "click .save_mailbox": "buttonSave",
        "click .delete_mailbox": "buttonDelete"
      };

      function MailboxView(model, collection) {
        this.model = model;
        this.collection = collection;
        this.buttonDelete = __bind(this.buttonDelete, this);
        MailboxView.__super__.constructor.call(this);
        this.model.view = this;
      }

      MailboxView.prototype.buttonEdit = function(event) {
        this.model.isEdit = true;
        return this.render();
      };

      MailboxView.prototype.buttonCancel = function(event) {
        this.model.isEdit = false;
        return this.render();
      };

      MailboxView.prototype.buttonSave = function(event) {
        var data, input;
        $(event.target).addClass("disabled").removeClass("buttonSave");
        input = this.$("input.content");
        data = {};
        input.each(function(i) {
          return data[input[i].id] = input[i].value;
        });
        this.model.save(data);
        this.collection.trigger("update_menu");
        this.model.isEdit = false;
        return this.render();
      };

      MailboxView.prototype.buttonDelete = function(event) {
        $(event.target).addClass("disabled").removeClass("delete_mailbox");
        return this.model.destroy();
      };

      MailboxView.prototype.render = function() {
        var template;
        if (this.model.isEdit) {
          template = require('./templates/_mailbox/mailbox_edit');
        } else {
          template = require('./templates/_mailbox/mailbox');
        }
        $(this.el).html(template({
          "model": this.model.toJSON()
        }));
        return this;
      };

      return MailboxView;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/mailboxes_menu_view": function(exports, require, module) {
  (function() {
    var MailboxMenuView,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    MailboxMenuView = require("./mailbox_menu_view").MailboxMenuView;

    exports.MailboxesMenuList = (function(_super) {

      __extends(MailboxesMenuList, _super);

      MailboxesMenuList.prototype.total_inbox = 0;

      function MailboxesMenuList(el, collection) {
        this.el = el;
        this.collection = collection;
        MailboxesMenuList.__super__.constructor.call(this);
        this.collection.view_menu_mailboxes = this;
        this.collection.on('reset', this.render, this);
        this.collection.on('add', this.render, this);
        this.collection.on('remove', this.render, this);
        this.collection.on('change', this.render, this);
      }

      MailboxesMenuList.prototype.events = {
        "change input.change_mailboxes_list": 'setupMailboxes'
      };

      MailboxesMenuList.prototype.setupMailboxes = function(event) {
        var data, element, input, _i, _len;
        input = $("input.change_mailboxes_list");
        data = {};
        for (_i = 0, _len = input.length; _i < _len; _i++) {
          element = input[_i];
          if (element.checked) data[element.id] = true;
        }
        this.collection.active_mailboxes = data;
        return this.collection.trigger("change_active_mailboxes");
      };

      MailboxesMenuList.prototype.render = function() {
        var _this = this;
        $(this.el).html("");
        this.total_inbox = 0;
        this.collection.each(function(mail) {
          var box;
          box = new MailboxMenuView(mail, mail.collection);
          $(_this.el).append(box.render().el);
          return _this.total_inbox += Number(mail.get("new_messages"));
        });
        return this;
      };

      return MailboxesMenuList;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/mailboxes_new_view": function(exports, require, module) {
  (function() {
    var Mailbox,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    Mailbox = require("../models/mailbox").Mailbox;

    exports.MailboxesNew = (function(_super) {

      __extends(MailboxesNew, _super);

      MailboxesNew.prototype.id = "mailboxeslist_new";

      MailboxesNew.prototype.className = "mailboxes_new";

      MailboxesNew.prototype.events = {
        "click #add_mailbox": 'addMailbox'
      };

      function MailboxesNew(el, collection) {
        this.el = el;
        this.collection = collection;
        MailboxesNew.__super__.constructor.call(this);
      }

      MailboxesNew.prototype.addMailbox = function(event) {
        var newbox;
        event.preventDefault();
        newbox = new Mailbox;
        newbox.isEdit = true;
        return this.collection.add(newbox);
      };

      MailboxesNew.prototype.render = function() {
        $(this.el).html(require('./templates/_mailbox/mailbox_new'));
        return this;
      };

      return MailboxesNew;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/mailboxes_view": function(exports, require, module) {
  (function() {
    var Mailbox, MailboxView,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    MailboxView = require("./mailbox_view").MailboxView;

    Mailbox = require("../models/mailbox").Mailbox;

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
        box = new MailboxView(mail, mail.collection);
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

window.require.define({"views/mails_column_view": function(exports, require, module) {
  (function() {
    var Mail, MailsList, MailsMore,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    Mail = require("../models/mail").Mail;

    MailsList = require("./mails_view").MailsList;

    MailsMore = require("./mails_more_view").MailsMore;

    exports.MailsColumnList = (function(_super) {

      __extends(MailsColumnList, _super);

      MailsColumnList.prototype.id = "mailboxeslist";

      MailsColumnList.prototype.className = "mailboxes";

      function MailsColumnList(el, collection) {
        this.el = el;
        this.collection = collection;
        MailsColumnList.__super__.constructor.call(this);
      }

      MailsColumnList.prototype.render = function() {
        $(this.el).html(require('./templates/_mail/mails'));
        this.view_mails_list = new MailsList(this.$("#mails_list_container"), this.collection);
        this.view_mails_list_more = new MailsMore(this.$("#button_load_more_mails"), this.collection);
        this.view_mails_list.render();
        this.view_mails_list_more.render();
        return this;
      };

      return MailsColumnList;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/mails_more_view": function(exports, require, module) {
  (function() {
    var Mail, MailListView,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    MailListView = require("./mail_list_view").MailListView;

    Mail = require("../models/mail").Mail;

    exports.MailsMore = (function(_super) {

      __extends(MailsMore, _super);

      function MailsMore(el, collection) {
        this.el = el;
        this.collection = collection;
        MailsMore.__super__.constructor.call(this);
      }

      MailsMore.prototype.render = function() {
        $(this.el).html(require("./templates/_mail/mails_more"));
        return this;
      };

      return MailsMore;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/mails_view": function(exports, require, module) {
  (function() {
    var Mail, MailListView,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    MailListView = require("./mail_list_view").MailListView;

    Mail = require("../models/mail").Mail;

    /*
    
      View to generate the list of mails - the second column from the left.
      Uses MailListView to generate each mail's view
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
        return this.collection.fetch();
      };

      MailsList.prototype.addOne = function(mail) {
        var box;
        box = new MailListView(mail, mail.collection);
        return $(this.el).append(box.render().el);
      };

      MailsList.prototype.render = function() {
        var _this = this;
        $(this.el).html("");
        this.collection.each(function(m) {
          return _this.addOne(m);
        });
        return this;
      };

      return MailsList;

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
  buf.push('><p>' + escape((interp = model.headers.from) == null ? '' : interp) + '\n<i');
  buf.push(attrs({ 'style':('color: lightgray;') }));
  buf.push('>' + escape((interp = model.headers.date) == null ? '' : interp) + '</i></p><h4>' + escape((interp = model.subject) == null ? '' : interp) + '</h4><p>' + escape((interp = model.html) == null ? '' : interp) + '\n</p></div><div');
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
  buf.push('<td><p>' + escape((interp = model.headers.from) == null ? '' : interp) + '\n<i');
  buf.push(attrs({ 'style':('color: lightgray;') }));
  buf.push('>' + escape((interp = model.headers.date) == null ? '' : interp) + '</i></p><p>' + escape((interp = model.subject) == null ? '' : interp) + '</p></td><td></td>');
  }
  else
  {
  buf.push('<td><p>' + escape((interp = model.headers.from) == null ? '' : interp) + '\n<i');
  buf.push(attrs({ 'style':('color: lightgray;') }));
  buf.push('>' + escape((interp = model.headers.date) == null ? '' : interp) + '</i></p><p>' + escape((interp = model.subject) == null ? '' : interp) + '</p></td><td><a');
  buf.push(attrs({ "class": ('btn') + ' ' + ('btn-mini') + ' ' + ('choose_mail_button') }));
  buf.push('><i');
  buf.push(attrs({ "class": ('icon-arrow-right') }));
  buf.push('></i></a></td>');
  }
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
  buf.push(attrs({ "class": ('button_more_mails') + ' ' + ('btn') + ' ' + ('btn-primary') }));
  buf.push('><i');
  buf.push(attrs({ "class": ('icon-plus') }));
  buf.push('></i>Load 25 older messages\n</a></div>');
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
  buf.push('<form>' + escape((interp = model.name) == null ? '' : interp) + '\n' + escape((interp = model.createdAt) == null ? '' : interp) + '\n' + escape((interp = model.SMTP_server) == null ? '' : interp) + '\n<a');
  buf.push(attrs({ 'type':('submit'), "class": ('edit_mailbox') + ' ' + ('isntEdit') + ' ' + ('btn') }));
  buf.push('>Edit</a><a');
  buf.push(attrs({ 'type':('submit'), "class": ('delete_mailbox') + ' ' + ('isntEdit') + ' ' + ('btn') + ' ' + ('btn-danger') }));
  buf.push('>Delete</a></form>');
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
  buf.push('<input');
  buf.push(attrs({ 'id':("name"), 'value':("" + (model.name) + ""), "class": ('content') }));
  buf.push('/><input');
  buf.push(attrs({ 'id':("createdAt"), 'value':("" + (model.createdAt) + ""), "class": ('content') }));
  buf.push('/><input');
  buf.push(attrs({ 'id':("SMTP_server"), 'value':("" + (model.SMTP_server) + ""), "class": ('content') }));
  buf.push('/><input');
  buf.push(attrs({ 'type':('submit'), 'value':("Save"), "class": ('save_mailbox') + ' ' + ('isEdit') + ' ' + ('btn') + ' ' + ('btn-success') }));
  buf.push('/><a');
  buf.push(attrs({ "class": ('cancel_edit_mailbox') + ' ' + ('isEdit') + ' ' + ('btn') + ' ' + ('btn-warning') }));
  buf.push('>Cancel</a>');
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
  buf.push(attrs({ 'href':('#') }));
  buf.push('><input');
  buf.push(attrs({ 'type':('checkbox'), 'id':(model.id), "class": ('change_mailboxes_list') }));
  buf.push('/> ' + escape((interp = model.name) == null ? '' : interp) + '\n');
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
  buf.push('>Inbox\n</a></li><li><a');
  buf.push(attrs({ 'href':('#') }));
  buf.push('>Sent</a></li><li><a');
  buf.push(attrs({ 'href':('#') }));
  buf.push('>Drafts</a></li><li><a');
  buf.push(attrs({ 'href':('#') }));
  buf.push('>Bin</a></li><li');
  buf.push(attrs({ "class": ('divider') }));
  buf.push('></li><li');
  buf.push(attrs({ "class": ('nav-header') }));
  buf.push('>Mailboxes</li></ul><ul');
  buf.push(attrs({ 'id':('menu_mailboxes'), "class": ('nav') + ' ' + ('nav-list') }));
  buf.push('></ul><ul');
  buf.push(attrs({ "class": ('nav') + ' ' + ('nav-list') }));
  buf.push('><li><a');
  buf.push(attrs({ 'href':('#config-mailboxes') }));
  buf.push('>add/modify\n</a></li><li');
  buf.push(attrs({ "class": ('divider') }));
  buf.push('></li><li');
  buf.push(attrs({ "class": ('nav-header') }));
  buf.push('>Filters</li><li><a');
  buf.push(attrs({ 'href':('#') }));
  buf.push('>Marked</a></li><li><a');
  buf.push(attrs({ 'href':('#') }));
  buf.push('>New</a></li><li><a');
  buf.push(attrs({ 'href':('#') }));
  buf.push('>Today</a></li><li><a');
  buf.push(attrs({ 'href':('#') }));
  buf.push('>Yesterday</a></li></ul>');
  }
  return buf.join("");
  };
}});


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

      MailboxCollection.prototype.removeOne = function(mailbox, view) {
        mailbox.destroy({
          success: function() {
            return view.remove();
          },
          error: function() {
            return alert("error");
          }
        });
        return view.remove();
      };

      return MailboxCollection;

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
    var AppView, BrunchApplication, MainRouter,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    BrunchApplication = require('helpers').BrunchApplication;

    MainRouter = require('routers/main_router').MainRouter;

    AppView = require('views/app_view').AppView;

    exports.Application = (function(_super) {

      __extends(Application, _super);

      function Application() {
        Application.__super__.constructor.apply(this, arguments);
      }

      Application.prototype.initialize = function() {
        this.router = new MainRouter;
        return this.appView = new AppView;
      };

      return Application;

    })(BrunchApplication);

    window.app = new exports.Application;

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
        'config': 0,
        'name': "Mailbox",
        'createdAt': "0",
        'SMTP_server': "smtp.gmail.com",
        'SMTP_port': "465",
        'SMTP_login': "login",
        'SMTP_pass': "pass",
        'SMTP_send_as': "You"
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
        '': 'home'
      };

      MainRouter.prototype.home = function() {
        return app.appView.render();
      };

      return MainRouter;

    })(Backbone.Router);

  }).call(this);
  
}});

window.require.define({"views/app_view": function(exports, require, module) {
  (function() {
    var MailboxCollection, MailboxesList,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    MailboxCollection = require('../collections/mailboxes').MailboxCollection;

    MailboxesList = require('../views/mailboxes_view').MailboxesList;

    exports.AppView = (function(_super) {

      __extends(AppView, _super);

      AppView.prototype.id = 'home-view';

      AppView.prototype.el = 'body';

      AppView.prototype.initialize = function() {};

      function AppView() {
        AppView.__super__.constructor.call(this);
        this.mailboxCollection = new MailboxCollection;
      }

      AppView.prototype.render = function() {
        $(this.el).html(require('./templates/app'));
        this.container_menu = this.$("#menu_container");
        this.container_content = this.$("#content");
        this.container_content.html(require('./templates/layout_mailboxes'));
        window.app.view_mailboxes = new MailboxesList($("#content"), this.mailboxCollection);
        window.app.view_mailboxes.render();
        return this;
      };

      AppView.prototype.set_layout_mailboxes = function(view) {};

      AppView.prototype.add_mailbox = function(event) {
        event.preventDefault();
        return this.mailboxesList.append(require('./templates/add_new_mailbox'));
      };

      return AppView;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/mailbox_view": function(exports, require, module) {
  (function() {
    var Mailbox,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    Mailbox = require("../models/mailbox").Mailbox;

    exports.MailboxView = (function(_super) {

      __extends(MailboxView, _super);

      MailboxView.prototype.className = "mailbox_well well";

      MailboxView.prototype.tagName = "div";

      MailboxView.prototype.isEdit = false;

      function MailboxView(model, collection) {
        this.model = model;
        this.collection = collection;
        MailboxView.__super__.constructor.call(this);
      }

      MailboxView.prototype.events = {
        "click .edit_mailbox": "edit",
        "click .save_mailbox": "save",
        "click .delete_mailbox": "delete"
      };

      MailboxView.prototype.edit = function(event) {
        this.isEdit = true;
        return this.render();
      };

      MailboxView.prototype.save = function(event) {
        var data, input;
        input = this.$("input.content");
        data = {};
        input.each(function(i) {
          return data[input[i].id] = input[i].value;
        });
        this.model.save(data);
        this.isEdit = false;
        return this.render();
      };

      MailboxView.prototype["delete"] = function(event) {
        console.log(this);
        return this.collection.removeOne(this.model, this);
      };

      MailboxView.prototype.render = function() {
        var template;
        if (this.isEdit) {
          template = require('./templates/mailbox_edit');
          $(this.el).html(template({
            "model": this.model.toJSON()
          }));
          this.$(".isntEdit").hide();
          this.$(".isEdit").show();
        } else {
          template = require('./templates/mailbox');
          $(this.el).html(template({
            "model": this.model.toJSON()
          }));
          this.$(".isntEdit").show();
          this.$(".isEdit").hide();
        }
        return this;
      };

      return MailboxView;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/mailboxes_view": function(exports, require, module) {
  (function() {
    var MailboxView,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    MailboxView = require("./mailbox_view").MailboxView;

    exports.MailboxesList = (function(_super) {

      __extends(MailboxesList, _super);

      MailboxesList.prototype.id = "mailboxeslist";

      MailboxesList.prototype.className = "mailboxes";

      function MailboxesList(el, collection) {
        this.el = el;
        this.collection = collection;
        MailboxesList.__super__.constructor.call(this);
      }

      MailboxesList.prototype.initialize = function() {
        this.collection.fetch();
        return this.collection.add([
          {
            "name": "miko",
            server: "s1"
          }, {
            "name": "miko2",
            server: "s2"
          }
        ]);
      };

      MailboxesList.prototype.addOne = function(mail) {
        var box;
        box = new MailboxView(mail, mail.collection);
        return $("#mail_list_container").append(box.render().el);
      };

      MailboxesList.prototype.render = function() {
        this.collection.each(this.addOne);
        return this;
      };

      return MailboxesList;

    })(Backbone.View);

  }).call(this);
  
}});

window.require.define({"views/templates/add_new_mailbox": function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<form');
  buf.push(attrs({ "class": ('well') }));
  buf.push('><button');
  buf.push(attrs({ 'id':('add_mailbox'), 'type':('submit'), "class": ('btn') }));
  buf.push('>Add a new mailbox</button></form>');
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
  buf.push(attrs({ "class": ('well') + ' ' + ('sidebar-nav') }));
  buf.push('><ul');
  buf.push(attrs({ 'id':('menu_container'), "class": ('nav') + ' ' + ('nav-list') }));
  buf.push('><li');
  buf.push(attrs({ "class": ('nav-header') }));
  buf.push('>All your mail</li><li');
  buf.push(attrs({ "class": ('active') }));
  buf.push('><a');
  buf.push(attrs({ 'href':('#') }));
  buf.push('>Inbox\n<span');
  buf.push(attrs({ "class": ('badge') + ' ' + ('badge-warning') }));
  buf.push('>8</span></a></li><li><a');
  buf.push(attrs({ 'href':('#') }));
  buf.push('>Sent</a></li><li><a');
  buf.push(attrs({ 'href':('#') }));
  buf.push('>Drafts</a></li><li><a');
  buf.push(attrs({ 'href':('#') }));
  buf.push('>Bin</a></li><li');
  buf.push(attrs({ "class": ('divider') }));
  buf.push('></li><li');
  buf.push(attrs({ "class": ('nav-header') }));
  buf.push('>Mailboxes</li><li><a');
  buf.push(attrs({ 'href':('#') }));
  buf.push('><input');
  buf.push(attrs({ 'type':('checkbox') }));
  buf.push('/>user@gmail.com\n<span');
  buf.push(attrs({ "class": ('badge') + ' ' + ('badge-warning') }));
  buf.push('>5</span></a></li><li><a');
  buf.push(attrs({ 'href':('#') }));
  buf.push('><input');
  buf.push(attrs({ 'type':('checkbox') }));
  buf.push('/>yeah@yahoo.com\n<span');
  buf.push(attrs({ "class": ('badge') + ' ' + ('badge-warning') }));
  buf.push('>3</span></a></li><li><a');
  buf.push(attrs({ 'href':('#') }));
  buf.push('><input');
  buf.push(attrs({ 'type':('checkbox') }));
  buf.push('/>imhot@yahoo.fr\n<span');
  buf.push(attrs({ "class": ('badge') + ' ' + ('badge-warning') + ' ' + ('hide') }));
  buf.push('>0</span></a></li><li><a');
  buf.push(attrs({ 'href':('#') }));
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
  buf.push('>Yesterday</a></li></ul></div></div><div');
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

window.require.define({"views/templates/layout_mailboxes": function(exports, require, module) {
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
  buf.push('><form');
  buf.push(attrs({ "class": ('well') }));
  buf.push('><a');
  buf.push(attrs({ 'id':('add_mailbox'), 'href':("#"), "class": ('btn') }));
  buf.push('>Add a new mailbox</a></form></div></div>');
  }
  return buf.join("");
  };
}});

window.require.define({"views/templates/mailbox": function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<form>' + escape((interp = model.name) == null ? '' : interp) + '\n' + escape((interp = model.createdAt) == null ? '' : interp) + '\n' + escape((interp = model.SMTP_server) == null ? '' : interp) + '\n<a');
  buf.push(attrs({ 'type':('submit'), "class": ('edit_mailbox') + ' ' + ('isntEdit') + ' ' + ('btn') }));
  buf.push('>Edit</a><a');
  buf.push(attrs({ 'type':('submit'), "class": ('save_mailbox') + ' ' + ('isEdit') + ' ' + ('btn') }));
  buf.push('>Save</a><a');
  buf.push(attrs({ 'type':('submit'), "class": ('delete_mailbox') + ' ' + ('isEdit') + ' ' + ('btn') }));
  buf.push('>Delete</a></form>');
  }
  return buf.join("");
  };
}});

window.require.define({"views/templates/mailbox_edit": function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<form><input');
  buf.push(attrs({ 'id':("name"), 'value':("" + (model.name) + ""), "class": ('content') }));
  buf.push('/><input');
  buf.push(attrs({ 'id':("createdAt"), 'value':("" + (model.createdAt) + ""), "class": ('content') }));
  buf.push('/><input');
  buf.push(attrs({ 'id':("SMTP_server"), 'value':("" + (model.SMTP_server) + ""), "class": ('content') }));
  buf.push('/><a');
  buf.push(attrs({ 'type':('submit'), "class": ('edit_mailbox') + ' ' + ('isntEdit') + ' ' + ('btn') }));
  buf.push('>Edit</a><input');
  buf.push(attrs({ 'type':('submit'), 'value':("Save"), "class": ('save_mailbox') + ' ' + ('isEdit') + ' ' + ('btn') + ' ' + ('btn-success') }));
  buf.push('/><a');
  buf.push(attrs({ 'type':('submit'), "class": ('delete_mailbox') + ' ' + ('isEdit') + ' ' + ('btn') + ' ' + ('btn-danger') }));
  buf.push('>Delete</a></form>');
  }
  return buf.join("");
  };
}});


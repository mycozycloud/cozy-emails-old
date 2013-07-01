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

  var define = function(bundle, fn) {
    if (typeof bundle === 'object') {
      for (var key in bundle) {
        if (has(bundle, key)) {
          modules[key] = bundle[key];
        }
      }
    } else {
      modules[bundle] = fn;
    }
  };

  globals.require = require;
  globals.require.define = define;
  globals.require.register = define;
  globals.require.brunch = true;
})();

window.require.register("collections/attachments", function(exports, require, module) {
  var _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  exports.AttachmentsCollection = (function(_super) {
    __extends(AttachmentsCollection, _super);

    function AttachmentsCollection() {
      _ref = AttachmentsCollection.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    AttachmentsCollection.prototype.comparator = 'filename';

    AttachmentsCollection.prototype.model = require('models/attachment');

    return AttachmentsCollection;

  })(Backbone.Collection);
  
});
window.require.register("collections/folders", function(exports, require, module) {
  var _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  exports.FolderCollection = (function(_super) {
    __extends(FolderCollection, _super);

    function FolderCollection() {
      _ref = FolderCollection.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    FolderCollection.prototype.model = require('models/folder').Folder;

    FolderCollection.prototype.url = 'folders';

    return FolderCollection;

  })(Backbone.Collection);
  
});
window.require.register("collections/logmessages", function(exports, require, module) {
  var LogMessage, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  LogMessage = require("models/logmessage").LogMessage;

  /*
      @file: logmessages.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description:
          Backbone collection for holding log messages objects.
  */


  exports.LogMessagesCollection = (function(_super) {
    __extends(LogMessagesCollection, _super);

    function LogMessagesCollection() {
      _ref = LogMessagesCollection.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    LogMessagesCollection.prototype.model = LogMessage;

    LogMessagesCollection.prototype.urlRoot = 'logs/';

    LogMessagesCollection.prototype.comparator = "createdAt";

    return LogMessagesCollection;

  })(Backbone.Collection);
  
});
window.require.register("collections/mailboxes", function(exports, require, module) {
  var Mailbox, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Mailbox = require("models/mailbox").Mailbox;

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
      _ref = MailboxCollection.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    MailboxCollection.prototype.comparator = 'name';

    MailboxCollection.prototype.model = Mailbox;

    MailboxCollection.prototype.url = 'mailboxes/';

    MailboxCollection.prototype.activeMailboxes = [];

    MailboxCollection.prototype.initialize = function() {
      return this.on('add', this.addView, this);
    };

    MailboxCollection.prototype.updateActiveMailboxes = function() {
      var _this = this;
      this.activeMailboxes = [];
      this.each(function(mailbox) {
        if (mailbox.get('checked')) {
          return _this.activeMailboxes.push(mailbox.get('id'));
        }
      });
      return this.trigger('change_active_mailboxes', this);
    };

    return MailboxCollection;

  })(Backbone.Collection);
  
});
window.require.register("collections/mails", function(exports, require, module) {
  var Mail, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Mail = require("models/mail").Mail;

  /*
      @file: mails.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description:
          The collection to store emails - gets populated with the content of
          the database.
  */


  exports.MailsCollection = (function(_super) {
    __extends(MailsCollection, _super);

    function MailsCollection() {
      _ref = MailsCollection.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    MailsCollection.prototype.model = Mail;

    MailsCollection.prototype.url = 'mails/';

    MailsCollection.prototype.timestampNew = new Date().valueOf();

    MailsCollection.prototype.timestampOld = new Date().valueOf();

    MailsCollection.prototype.timestampMiddle = new Date().valueOf();

    MailsCollection.prototype.mailsAtOnce = 100;

    MailsCollection.prototype.fetchOlder = function(options) {
      var success,
        _this = this;
      success = options.success || function() {};
      if (options == null) {
        options = {};
      }
      options.url = "folders/" + this.timestampOld + "/" + this.mailsAtOnce + "/" + this.lastIdOld;
      options.remove = false;
      options.success = function(collection) {
        if (_this.length > 0) {
          _this.timestampNew = _this.at(0).get("dateValueOf");
        }
        return success.call(_this, arguments);
      };
      return this.fetch(options);
    };

    MailsCollection.prototype.fetchFolder = function(folderid, limit) {
      var _this = this;
      return this.fetch({
        url: "folders/" + folderid + "/" + limit + "/undefined",
        success: function(collection) {
          _this.folderId = folderid;
          if (_this.length > 0) {
            _this.timestampNew = _this.at(0).get("dateValueOf");
          }
          if (_this.length > 0) {
            return _this.timestampOld = _this.last().get("dateValueOf");
          }
        }
      });
    };

    return MailsCollection;

  })(Backbone.Collection);
  
});
window.require.register("helpers", function(exports, require, module) {
  exports.BrunchApplication = (function() {
    function BrunchApplication() {
      var _this = this;
      $(function() {
        _this.initialize(_this);
        return Backbone.history.start();
      });
    }

    BrunchApplication.prototype.initializeJQueryExtensions = function() {
      return $.fn.spin = function(opts, color) {
        var presets;
        presets = {
          tiny: {
            lines: 8,
            length: 2,
            width: 1,
            radius: 3
          },
          small: {
            lines: 10,
            length: 2,
            width: 3,
            radius: 5
          },
          large: {
            lines: 10,
            length: 8,
            width: 4,
            radius: 8
          }
        };
        if (Spinner) {
          return this.each(function() {
            var $this, spinner;
            $this = $(this);
            spinner = $this.data("spinner");
            if (spinner != null) {
              spinner.stop();
              return $this.data("spinner", null);
            } else if (opts !== false) {
              if (typeof opts === "string") {
                if (opts in presets) {
                  opts = presets[opts];
                } else {
                  opts = {};
                }
                if (color) {
                  opts.color = color;
                }
              }
              spinner = new Spinner($.extend({
                color: $this.css("color")
              }, opts));
              spinner.spin(this);
              return $this.data("spinner", spinner);
            }
          });
        }
      };
    };

    BrunchApplication.prototype.initialize = function() {
      return null;
    };

    return BrunchApplication;

  })();
  
});
window.require.register("initialize", function(exports, require, module) {
  /*
      @file: initialize.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description:
          Building object used all over the place - collections, AppView, etc
  */

  var BrunchApplication, FolderCollection, MailboxCollection, MailboxesList, MailsCollection, MailsList, MainRouter, Menu, Modal, SocketListener, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  BrunchApplication = require('helpers').BrunchApplication;

  MainRouter = require('routers/main_router').MainRouter;

  MailsCollection = require('collections/mails').MailsCollection;

  FolderCollection = require('collections/folders').FolderCollection;

  MailboxCollection = require('collections/mailboxes').MailboxCollection;

  MailboxesList = require('views/mailboxes_list').MailboxesList;

  MailsList = require('views/mails_list').MailsList;

  Menu = require('views/menu').Menu;

  Modal = require('views/modal').Modal;

  SocketListener = require('lib/realtimer');

  exports.Application = (function(_super) {
    __extends(Application, _super);

    function Application() {
      _ref = Application.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Application.prototype.initialize = function() {
      var _this = this;
      this.initializeJQueryExtensions();
      this.mailboxes = new MailboxCollection();
      this.router = new MainRouter;
      this.realtimer = new SocketListener();
      this.views = {};
      this.views.menu = new Menu();
      this.views.menu.render().$el.appendTo($('body'));
      this.mailboxes = new MailboxCollection();
      this.realtimer.watch(this.mailboxes);
      this.views.mailboxList = new MailboxesList({
        collection: this.mailboxes
      });
      this.views.mailboxList.$el.appendTo($('body'));
      this.views.mailboxList.render();
      this.mailboxes.fetch({
        error: function() {
          return alert("Error while loading mailboxes");
        }
      });
      this.folders = new FolderCollection();
      this.folders.fetch({
        success: function() {
          return _this.folders.each(function(folder) {
            console.log(folder);
            if (folder.get('specialType') === 'ALLMAIL') {
              return _this.mails.fetchFolder(folder.id, 100);
            }
          });
        },
        error: function() {
          return alert("Error while loading folders");
        }
      });
      this.mails = new MailsCollection();
      this.realtimer.watch(this.mails);
      this.views.mailList = new MailsList({
        collection: this.mails
      });
      this.views.mailList.$el.appendTo($('body'));
      this.views.mailList.render();
      this.views.modal = new Modal();
      return this.views.modal.render().$el.appendTo($('body'));
    };

    return Application;

  })(BrunchApplication);

  window.app = new exports.Application;
  
});
window.require.register("lib/base_view", function(exports, require, module) {
  var BaseView, _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  module.exports = BaseView = (function(_super) {
    __extends(BaseView, _super);

    function BaseView() {
      this.render = __bind(this.render, this);
      _ref = BaseView.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    BaseView.prototype.initialize = function(options) {
      return this.options = options;
    };

    BaseView.prototype.template = function() {};

    BaseView.prototype.getRenderData = function() {};

    BaseView.prototype.render = function() {
      var data;
      data = _.extend({}, this.options, this.getRenderData());
      this.$el.html(this.template(data));
      this.afterRender();
      return this;
    };

    BaseView.prototype.afterRender = function() {};

    return BaseView;

  })(Backbone.View);
  
});
window.require.register("lib/realtimer", function(exports, require, module) {
  var Mail, Mailbox, SocketListener, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Mailbox = require('models/mailbox').Mailbox;

  Mail = require('models/mail').Mail;

  module.exports = SocketListener = (function(_super) {
    __extends(SocketListener, _super);

    function SocketListener() {
      _ref = SocketListener.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    SocketListener.prototype.models = {
      'mailbox': Mailbox,
      'mail': Mail
    };

    SocketListener.prototype.events = ['mailbox.create', 'mailbox.update', 'mailbox.delete', 'mail.create', 'mail.update', 'mail.delete'];

    SocketListener.prototype.onRemoteCreate = function(model) {
      if (model instanceof Mailbox) {
        this.collections[0].add(model);
      }
      if (model instanceof Mail && this.collections[1].folderId === model.folder) {
        return this.collections[1].add(model);
      }
    };

    SocketListener.prototype.onRemoteDelete = function(model) {
      return model.trigger('destroy', model, model.collection, {});
    };

    return SocketListener;

  })(CozySocketListener);
  
});
window.require.register("lib/view_collection", function(exports, require, module) {
  var BaseView, ViewCollection, _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  BaseView = require('lib/base_view');

  module.exports = ViewCollection = (function(_super) {
    __extends(ViewCollection, _super);

    function ViewCollection() {
      this.removeItem = __bind(this.removeItem, this);
      this.addItem = __bind(this.addItem, this);
      _ref = ViewCollection.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    ViewCollection.prototype.views = {};

    ViewCollection.prototype.itemView = null;

    ViewCollection.prototype.itemViewOptions = function() {};

    ViewCollection.prototype.checkIfEmpty = function() {
      return this.$el.toggleClass('empty', _.size(this.views) === 0);
    };

    ViewCollection.prototype.appendView = function(view) {
      return this.$el.append(view.el);
    };

    ViewCollection.prototype.initialize = function() {
      ViewCollection.__super__.initialize.apply(this, arguments);
      this.views = {};
      this.listenTo(this.collection, "reset", this.onReset);
      this.listenTo(this.collection, "add", this.addItem);
      this.listenTo(this.collection, "remove", this.removeItem);
      return this.onReset(this.collection);
    };

    ViewCollection.prototype.render = function() {
      var id, view, _ref1;
      _ref1 = this.views;
      for (id in _ref1) {
        view = _ref1[id];
        view.$el.detach();
      }
      return ViewCollection.__super__.render.apply(this, arguments);
    };

    ViewCollection.prototype.afterRender = function() {
      var id, view, _ref1;
      _ref1 = this.views;
      for (id in _ref1) {
        view = _ref1[id];
        this.appendView(view);
      }
      return this.checkIfEmpty(this.views);
    };

    ViewCollection.prototype.remove = function() {
      this.onReset([]);
      return ViewCollection.__super__.remove.apply(this, arguments);
    };

    ViewCollection.prototype.onReset = function(newcollection) {
      var id, view, _ref1;
      _ref1 = this.views;
      for (id in _ref1) {
        view = _ref1[id];
        view.remove();
      }
      return newcollection.forEach(this.addItem);
    };

    ViewCollection.prototype.addItem = function(model) {
      var options, view;
      options = _.extend({}, {
        model: model
      }, this.itemViewOptions(model));
      view = new this.itemView(options);
      this.views[model.cid] = view.render();
      this.appendView(view);
      return this.checkIfEmpty(this.views);
    };

    ViewCollection.prototype.removeItem = function(model) {
      this.views[model.cid].remove();
      delete this.views[model.cid];
      return this.checkIfEmpty(this.views);
    };

    return ViewCollection;

  })(BaseView);
  
});
window.require.register("models/attachment", function(exports, require, module) {
  var BaseModel, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

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
      _ref = Attachment.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    return Attachment;

  })(BaseModel);
  
});
window.require.register("models/folder", function(exports, require, module) {
  var BaseModel, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  BaseModel = require("./models").BaseModel;

  exports.Folder = (function(_super) {
    __extends(Folder, _super);

    function Folder() {
      _ref = Folder.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    return Folder;

  })(BaseModel);
  
});
window.require.register("models/logmessage", function(exports, require, module) {
  var BaseModel, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  BaseModel = require("./models").BaseModel;

  /*
    @file: logmessage.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
      Model which represents a log message - displayed to user
  */


  exports.LogMessage = (function(_super) {
    __extends(LogMessage, _super);

    function LogMessage() {
      _ref = LogMessage.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    LogMessage.prototype.urlRoot = "logs/";

    LogMessage.prototype.idAttribute = "id";

    return LogMessage;

  })(BaseModel);
  
});
window.require.register("models/mail", function(exports, require, module) {
  var BaseModel, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

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
      _ref = Mail.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Mail.prototype.urlRoot = "mails/";

    Mail.prototype.initialize = function() {
      Mail.__super__.initialize.apply(this, arguments);
      return this.url = BaseModel.prototype.url;
    };

    Mail.prototype.getMailbox = function() {
      if (this.mailbox == null) {
        this.mailbox = window.app.mailboxes.get(this.get("mailbox"));
      }
      return this.mailbox;
    };

    Mail.prototype.getColor = function() {
      var _ref1;
      return ((_ref1 = this.getMailbox()) != null ? _ref1.get("color") : void 0) || "white";
    };

    Mail.prototype.parse = function(attributes) {
      if ('string' === typeof attributes.flags) {
        attributes.flags = JSON.parse(attributes.flags);
      }
      return attributes;
    };

    /*
        Changing mail properties - read and flagged
    */


    Mail.prototype.isRead = function() {
      return -1 !== _.indexOf(this.get('flags'), "\\Seen");
    };

    Mail.prototype.isFlagged = function() {
      return -1 !== _.indexOf(this.get('flags'), "\\Flagged");
    };

    Mail.prototype.markRead = function(read) {
      if (read == null) {
        read = true;
      }
      if (read) {
        return this.set('flags', _.union(this.get('flags'), ["\\Seen"]));
      } else {
        return this.set('flags', _.without(this.get('flags'), "\\Seen"));
      }
    };

    Mail.prototype.markFlagged = function(flagged) {
      if (flagged == null) {
        flagged = true;
      }
      if (flagged) {
        return this.set('flags', _.union(this.get('flags'), ["\\Flagged"]));
      } else {
        return this.set('flags', _.without(this.get('flags'), "\\Flagged"));
      }
    };

    /*
        RENDERING - these functions attr() replace @get "attr", and add
        some parsing logic.  To be used in views, to keep the maximum of
        logic related to mails in one place.
    */


    Mail.prototype.asEmailList = function(field, out) {
      var obj, parsed, _i, _len;
      parsed = JSON.parse(this.get(field));
      for (_i = 0, _len = parsed.length; _i < _len; _i++) {
        obj = parsed[_i];
        out += "" + obj.name + " <" + obj.address + ">, ";
      }
      return out.substring(0, out.length - 2);
    };

    Mail.prototype.from = function() {
      var out;
      out = "";
      if (this.get("from")) {
        this.asEmailList("from", out);
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
      var out;
      out = "";
      if (this.get("cc")) {
        out = this.asEmailList("cc", out);
      }
      console.log(out);
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
      var out;
      out = "";
      if (this.get("from")) {
        this.asEmailList("from", out);
      }
      if (this.get("cc")) {
        this.asEmailList("cc", out);
      }
      return out;
    };

    Mail.prototype.date = function() {
      var parsed;
      parsed = moment(this.get("date"));
      return parsed.calendar();
    };

    Mail.prototype.respondingToText = function() {
      return "" + (this.fromShort()) + " on " + (this.date()) + " wrote:";
    };

    Mail.prototype.subjectResponse = function(mode) {
      var subject;
      if (mode == null) {
        mode = "answer";
      }
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
      if (mode == null) {
        mode = "answer";
      }
      switch (mode) {
        case "answer_all":
          return this.cc();
        default:
          return "";
      }
    };

    Mail.prototype.toResponse = function(mode) {
      if (mode == null) {
        mode = "answer";
      }
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
      var expression, string;
      expression = new RegExp("(<style>(.|\s)*?</style>)", "gi");
      string = new String(this.get("html"));
      return string.replace(expression, "");
    };

    Mail.prototype.hasHtml = function() {
      var html;
      html = this.get("html");
      return (html != null) && html !== "";
    };

    Mail.prototype.hasText = function() {
      var text;
      text = this.get("text");
      return (text != null) && text !== "";
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

    Mail.prototype.textOrHtml = function() {
      if (this.hasText()) {
        return this.text();
      } else {
        return this.html();
      }
    };

    return Mail;

  })(BaseModel);
  
});
window.require.register("models/mail_sent", function(exports, require, module) {
  var BaseModel, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  BaseModel = require("./models").BaseModel;

  /*
    @file: mail_sent.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description: 
      Model which defines the sent MAIL object.
  */


  exports.MailSent = (function(_super) {
    __extends(MailSent, _super);

    function MailSent() {
      _ref = MailSent.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    MailSent.prototype.initialize = function() {
      this.on("destroy", this.removeView, this);
      return this.on("change", this.redrawView, this);
    };

    MailSent.prototype.mailbox = function() {
      if (!this.mailbox) {
        this.mailbox = window.app.mailboxes.get(this.get("mailbox"));
      }
      return this.mailbox;
    };

    MailSent.prototype.getColor = function() {
      var box;
      box = window.app.mailboxes.get(this.get("mailbox"));
      if (box) {
        return box.get("color");
      } else {
        return "white";
      }
    };

    MailSent.prototype.redrawView = function() {
      if (this.view != null) {
        return this.view.render();
      }
    };

    MailSent.prototype.removeView = function() {
      if (this.view != null) {
        return this.view.remove();
      }
    };

    /*
        RENDERING - these functions attr() replace @get "attr", and add some parsing logic.
        To be used in views, to keep the maximum of logic related to mails in one place.
    */


    MailSent.prototype.hasCC = function() {
      return this.get("cc") && JSON.parse(this.get("cc")).length > 0;
    };

    MailSent.prototype.cc = function() {
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

    MailSent.prototype.ccShort = function() {
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

    MailSent.prototype.hasBCC = function() {
      return this.get("bcc") && JSON.parse(this.get("bcc")).length > 0;
    };

    MailSent.prototype.bcc = function() {
      var obj, out, parsed, _i, _len;
      out = "";
      if (this.get("bcc")) {
        parsed = JSON.parse(this.get("bcc"));
        for (_i = 0, _len = parsed.length; _i < _len; _i++) {
          obj = parsed[_i];
          out += obj.name + " <" + obj.address + ">, ";
        }
      }
      return out;
    };

    MailSent.prototype.bccShort = function() {
      var obj, out, parsed, _i, _len;
      out = "";
      if (this.get("bcc")) {
        parsed = JSON.parse(this.get("bcc"));
        for (_i = 0, _len = parsed.length; _i < _len; _i++) {
          obj = parsed[_i];
          out += obj.name + " ";
        }
      }
      return out;
    };

    MailSent.prototype.to = function() {
      var obj, out, parsed, _i, _len;
      out = "";
      if (this.get("to")) {
        parsed = JSON.parse(this.get("to"));
        for (_i = 0, _len = parsed.length; _i < _len; _i++) {
          obj = parsed[_i];
          out += obj.name + " <" + obj.address + ">, ";
        }
      }
      return out;
    };

    MailSent.prototype.toShort = function() {
      var obj, out, parsed, _i, _len;
      out = "";
      if (this.get("to")) {
        parsed = JSON.parse(this.get("to"));
        for (_i = 0, _len = parsed.length; _i < _len; _i++) {
          obj = parsed[_i];
          if (obj.name) {
            out += obj.name + ", ";
          } else {
            out += obj.address + ", ";
          }
        }
      }
      return out;
    };

    MailSent.prototype.date = function() {
      var parsed;
      parsed = new Date(this.get("sentAt"));
      return parsed.toUTCString();
    };

    MailSent.prototype.text = function() {
      return this.get("text").replace(/\r\n|\r|\n/g, "<br />");
    };

    MailSent.prototype.html = function() {
      var exp, expression, string;
      expression = new RegExp("(<style>(.|\s)*?</style>)", "gi");
      exp = /\/(<style>(.|\s)*?<\/style>)\/ig/;
      string = new String(this.get("html"));
      return string.replace(expression, "");
    };

    MailSent.prototype.hasHtml = function() {
      var html;
      html = this.get("html");
      return (html != null) && html !== "";
    };

    MailSent.prototype.hasText = function() {
      var text;
      text = this.get("text");
      return (text != null) && text !== "";
    };

    MailSent.prototype.hasAttachments = function() {
      return this.get("hasAttachments");
    };

    MailSent.prototype.htmlOrText = function() {
      if (this.hasHtml()) {
        return this.html();
      } else {
        return this.text();
      }
    };

    MailSent.prototype.textOrHtml = function() {
      if (this.hasText()) {
        return this.text();
      } else {
        return this.html();
      }
    };

    return MailSent;

  })(BaseModel);
  
});
window.require.register("models/mailbox", function(exports, require, module) {
  var BaseModel, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  BaseModel = require("./models").BaseModel;

  /*
      @file: mailbox.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description:
          A model which defines the MAILBOX object.
          MAILBOX stocks all the data necessary for a successful connection to
          IMAP and SMTP servers, and all the data relative to this mailbox,
          internal to the application.
  */


  exports.Mailbox = (function(_super) {
    __extends(Mailbox, _super);

    function Mailbox() {
      _ref = Mailbox.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Mailbox.prototype.urlRoot = 'mailboxes/';

    Mailbox.prototype.defaults = {
      checked: true,
      config: 0,
      name: "box",
      login: "login",
      password: "pass",
      smtpServer: "smtp.gmail.com",
      smtpSsl: true,
      smtpSendAs: "support@mycozycloud.com",
      imapServer: "imap.gmail.com",
      imapPort: 993,
      imapSecure: true,
      color: "orange"
    };

    Mailbox.prototype.imapLastFetchedDate = function() {
      var parsed;
      parsed = new Date(this.get("IMapLastFetchedDate"));
      return parsed.toUTCString();
    };

    Mailbox.prototype.deltaNewMessages = function(delta) {
      var current;
      current = parseInt(this.get("newMessages"));
      return this.set("newMessages", current + delta);
    };

    return Mailbox;

  })(BaseModel);
  
});
window.require.register("models/models", function(exports, require, module) {
  var _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  exports.BaseModel = (function(_super) {
    __extends(BaseModel, _super);

    function BaseModel() {
      _ref = BaseModel.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    return BaseModel;

  })(Backbone.Model);
  
});
window.require.register("routers/main_router", function(exports, require, module) {
  var Mail, MailView, Mailbox, MailboxForm, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Mail = require("models/mail").Mail;

  MailView = require("views/mail").MailView;

  MailboxForm = require("views/mailboxes_list_form").MailboxForm;

  Mailbox = require("models/mailbox").Mailbox;

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
      _ref = MainRouter.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    MainRouter.prototype.routes = {
      '': 'index',
      'inbox': 'inbox',
      'folder/:id': 'folder',
      'mail/:id': 'mail',
      'config': 'config',
      'config/mailboxes': 'config',
      'config/mailboxes/new': 'newMailbox',
      'config/mailboxes/:id': 'editMailbox'
    };

    MainRouter.prototype.index = function() {
      return this.navigate('inbox', true);
    };

    MainRouter.prototype.clear = function() {
      var _ref1, _ref2;
      app.views.mailboxList.activate(null);
      app.views.mailList.activate(null);
      if ((_ref1 = app.views.mail) != null) {
        _ref1.remove();
      }
      if ((_ref2 = app.views.mailboxform) != null) {
        _ref2.remove();
      }
      app.views.mail = null;
      return app.views.mailboxform = null;
    };

    MainRouter.prototype.inbox = function() {
      var firstmail,
        _this = this;
      if (firstmail = app.mails.at(0)) {
        this.navigate("mail/" + firstmail.id, true);
        return;
      }
      app.mails.once('sync', function() {
        return _this.inbox();
      });
      this.clear();
      app.views.menu.select('inboxbutton');
      app.views.mailboxList.$el.hide();
      return app.views.mailList.$el.show();
    };

    MainRouter.prototype.folder = function(folderid) {
      this.inbox();
      return app.mails.fetchFolder(folderid, 100);
    };

    MainRouter.prototype.config = function() {
      this.clear();
      app.views.menu.select('mailboxesbutton');
      app.views.mailList.$el.hide();
      return app.views.mailboxList.$el.show();
    };

    MainRouter.prototype.newMailbox = function() {
      this.config();
      app.views.mailboxform = new MailboxForm({
        model: new Mailbox()
      });
      app.views.mailboxform.$el.appendTo($('body'));
      return app.views.mailboxform.render();
    };

    MainRouter.prototype.editMailbox = function(id) {
      var model;
      if (!(model = app.mailboxes.get(id))) {
        return this.navigate('config/mailboxes', true);
      }
      this.config();
      app.views.mailboxList.activate(id);
      app.views.mailboxform = new MailboxForm({
        model: model
      });
      app.views.mailboxform.$el.appendTo($('body'));
      return app.views.mailboxform.render();
    };

    MainRouter.prototype.mail = function(id) {
      var model, _ref1,
        _this = this;
      if (app.mails.length === 0) {
        return app.mails.on('sync', function() {
          return _this.mail(id);
        });
      }
      app.views.menu.select('inboxbutton');
      app.views.mailboxList.$el.hide();
      app.views.mailList.activate(id);
      app.views.mailList.$el.show();
      if ((_ref1 = app.views.mail) != null) {
        _ref1.remove();
      }
      if (model = app.mails.get(id)) {
        app.views.mail = new MailView({
          model: model
        });
        app.views.mail.$el.appendTo($('body'));
        return app.views.mail.render();
      } else {
        model = new Mail({
          id: id
        });
        model.fetch({
          success: function() {
            return app.views.mail.render();
          }
        });
        app.views.mail = new MailView({
          model: model
        });
        app.views.mail.$el.appendTo($('body'));
        return app.views.mail.render();
      }
    };

    return MainRouter;

  })(Backbone.Router);
  
});
window.require.register("templates/_attachment/attachment_element", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<i class="icon-file"></i><a');
  buf.push(attrs({ 'href':("" + (href) + ""), 'target':("_blank") }, {"href":true,"target":true}));
  buf.push('>' + escape((interp = attachment.get("fileName")) == null ? '' : interp) + '</a>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_layouts/layout_compose_mail", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div class="row-fluid"><div id="compose_mail_container" class="span12"></div></div>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_layouts/layout_mailboxes", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div><div id="mailboxes"></div><div id="add_mail_button_container"></div></div>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_layouts/layout_mails", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div class="row-fluid"><div id="column_mails_list" class="column span5"></div><div id="column_mail" class="column"></div></div>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_mail/attachments", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<h3 class="attachments-title">attachments</h3><div id="attachments_list"></div>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_mail/big", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div id="additional_bar" class="btn-toolbar"><a id="btn-flagged" class="btn btn-warning">');
  if ( model.isFlagged())
  {
  buf.push('<i class="icon-star-empty icon-white"></i>Unflag');
  }
  else
  {
  buf.push('<i class="icon-star icon-white"></i>Flag');
  }
  buf.push('</a><a id="btn-unread" class="btn">');
  if ( model.isRead())
  {
  buf.push('<i class="icon-eye-close icon-white"></i>Keep unread');
  }
  else
  {
  buf.push('<i class="icon-eye-open icon-white"></i>Read');
  }
  buf.push('</a><a id="btn-delete" class="btn btn-danger"><i class="icon-remove icon-white"></i>Delete</a></div><div class="well mail-panel"><p>' + escape((interp = model.fromShort()) == null ? '' : interp) + '<i class="date">' + escape((interp = model.date()) == null ? '' : interp) + '</i>');
  if ( model.get("cc"))
  {
  buf.push('<p>CC:  ' + escape((interp = model.cc()) == null ? '' : interp) + '</p>');
  }
  buf.push('</p><h3>' + escape((interp = model.get("subject")) == null ? '' : interp) + '</h3><br/>');
  if ( model.hasHtml())
  {
  buf.push('<iframe id="mail_content_html" name="mail_content_html">' + ((interp = model.html()) == null ? '' : interp) + '</iframe>');
  }
  else
  {
  buf.push('<div id="mail_content_text">' + ((interp = model.text()) == null ? '' : interp) + '</div>');
  }
  buf.push('</div><div id="answer_form"></div>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_mail/list", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div id="topbar"><a id="refresh-btn" class="btn btn-primary">Refresh</a><a id="markallread-btn" class="btn btn-primary">Mark all as read</a></div><div id="no-mails-message" class="well"><h3>Hey !</h3><p>It looks like there are no mails to show.</p><p>May be you need to configure your mailboxes :<a href="#config/mailboxes">Click Here</a></p><p>If You just did it, and still see no messages, you may need to wait for\nus to download them for you. Enjoy  :)\n</p></div><table class="table table-striped"><tbody id="mails_list_container"></tbody></table><div id="more-button"><a id="add_more_mails" class="btn btn-primary btn-large">more messages</a></div>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_mail/mail_answer", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<form class="well"><fieldset><div id="mail_basic" class="control-group"><p>');
  if ( mailtosend.get("mode") == "answer")
  {
  buf.push('Answering to ' + escape((interp = model.from()) == null ? '' : interp) + ' ...');
  }
  else if ( mailtosend.get("mode") == "answer_all")
  {
  buf.push('Answering to all ' + escape((interp = model.fromAndCc()) == null ? '' : interp) + ' ...');
  }
  else
  {
  buf.push('Forwarding ...');
  }
  buf.push('<a id="mail_detailed_view_button" class="btn-mini btn-primary">show&nbsp;details</a></p></div><div id="mail_to" class="control-group"><div class="controls"><div class="input-prepend"><span class="add-on">To&nbsp;</span><input');
  buf.push(attrs({ 'id':("to"), 'type':("text"), 'value':(model.toResponse(mailtosend.get("mode"))), "class": ('content') + ' ' + ('span6') + ' ' + ('input-xlarge') }, {"id":true,"type":true,"value":true}));
  buf.push('/></div></div></div><div id="mail_advanced" class="control-group"><div class="controls"><div class="input-prepend"><span class="add-on">Cc&nbsp;</span><input');
  buf.push(attrs({ 'id':("cc"), 'type':("text"), 'value':(model.ccResponse(mailtosend.get("mode"))), "class": ('content') + ' ' + ('span6') + ' ' + ('input-xlarge') }, {"id":true,"type":true,"value":true}));
  buf.push('/></div></div><div class="controls"><div class="input-prepend"><span class="add-on">Bcc</span><input id="bcc" type="text" value="" class="content span6 input-xlarge"/></div></div><div class="controls"><div class="input-prepend"><span class="add-on">Subject</span><input');
  buf.push(attrs({ 'id':("subject"), 'type':("text"), 'value':(model.subjectResponse(mailtosend.get("mode"))), "class": ('content') + ' ' + ('span9') + ' ' + ('input-xlarge') }, {"id":true,"type":true,"value":true}));
  buf.push('/></div></div></div><div class="control-group"><div class="controls"><div id="wysihtml5-toolbar" style="display: none;"><div class="btn-toolbar"><div class="btn-group"><a data-wysihtml5-command="bold" class="btn btn-mini">bold</a><a data-wysihtml5-command="italic" class="btn btn-mini">italic</a><a data-wysihtml5-command="underline" class="btn btn-mini">underline</a><a data-wysihtml5-command="insertUnorderedList" class="btn btn-mini">list</a></div><div class="btn-group"><a data-wysihtml5-command="foreColor" data-wysihtml5-command-value="red" class="btn btn-mini">red</a><a data-wysihtml5-command="foreColor" data-wysihtml5-command-value="green" class="btn btn-mini">green</a><a data-wysihtml5-command="foreColor" data-wysihtml5-command-value="blue" class="btn btn-mini">blue</a></div><div class="btn-group"><a data-wysihtml5-command="createLink" class="btn btn-mini">insert link</a></div><div data-wysihtml5-dialog="createLink" style="display: none;border: none;"><form class="form-inline"><input data-wysihtml5-dialog-field="href" value="http://" class="text"/><a data-wysihtml5-dialog-action="save" class="btn btn-mini">OK</a><a data-wysihtml5-dialog-action="cancel" class="btn btn-mini">Cancel</a></form></div></div></div></div><div class="controls"><textarea id="html" rows="15" cols="80" class="content span10 input-xlarge"><br/><br/><p><' + (model.respondingToText()) + '></' + (model.respondingToText()) + '></p><blockquote style="border-left: 3px lightgray solid; margin-left: 15px; padding-left: 5px; color: lightgray; font-style:italic;">' + ((interp = model.htmlOrText()) == null ? '' : interp) + '</blockquote></textarea><a id="send_button" class="btn btn-primary btn-large">Send !</a></div></div></fieldset></form>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_mail/mail_compose", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  if ( models.length > 0)
  {
  buf.push('<form class="well"><fieldset><div id="mail_from" class="control-group"><div class="controls"><div class="input-prepend"><span class="add-on">From:</span><select id="mailbox" class="content input-xlarge">');
  // iterate models
  ;(function(){
    if ('number' == typeof models.length) {

      for (var $index = 0, $$l = models.length; $index < $$l; $index++) {
        var mailbox = models[$index];

  buf.push('<option');
  buf.push(attrs({ 'value':(mailbox.get("id")) }, {"value":true}));
  buf.push('>' + escape((interp = mailbox.get("name")) == null ? '' : interp) + '</option>');
      }

    } else {
      var $$l = 0;
      for (var $index in models) {
        $$l++;      var mailbox = models[$index];

  buf.push('<option');
  buf.push(attrs({ 'value':(mailbox.get("id")) }, {"value":true}));
  buf.push('>' + escape((interp = mailbox.get("name")) == null ? '' : interp) + '</option>');
      }

    }
  }).call(this);

  buf.push('</select></div></div></div><div id="mail_to" class="control-group"><div class="controls"><div class="input-prepend"><span class="add-on">To&nbsp;</span><input id="to" type="text" class="content span6 input-xlarge"/></div></div></div><div id="mail_advanced" class="control-group"><div class="controls"><div class="input-prepend"><span class="add-on">Cc&nbsp;</span><input id="cc" type="text" class="content span6 input-xlarge"/></div></div><div class="controls"><div class="input-prepend"><span class="add-on">Bcc</span><input id="bcc" type="text" class="content span6 input-xlarge"/></div></div><div class="controls"><div class="input-prepend"><span class="add-on">Subject</span><input id="subject" type="text" class="content span9 input-xlarge"/></div></div></div><div class="control-group"><div class="controls"><div id="wysihtml5-toolbar" style="display: none;"><div class="btn-toolbar"><div class="btn-group"><a data-wysihtml5-command="bold" class="btn btn-mini">bold</a><a data-wysihtml5-command="italic" class="btn btn-mini">italic</a><a data-wysihtml5-command="underline" class="btn btn-mini">underline</a><a data-wysihtml5-command="insertUnorderedList" class="btn btn-mini">list</a></div><div class="btn-group"><a data-wysihtml5-command="foreColor" data-wysihtml5-command-value="red" class="btn btn-mini">red</a><a data-wysihtml5-command="foreColor" data-wysihtml5-command-value="green" class="btn btn-mini">green</a><a data-wysihtml5-command="foreColor" data-wysihtml5-command-value="blue" class="btn btn-mini">blue</a></div><div class="btn-group"><a data-wysihtml5-command="createLink" class="btn btn-mini">insert link</a></div><div data-wysihtml5-dialog="createLink" style="display: none;border: none;"><form class="form-inline"><input data-wysihtml5-dialog-field="href" value="http://" class="text"/><a data-wysihtml5-dialog-action="save" class="btn btn-mini">OK</a><a data-wysihtml5-dialog-action="cancel" class="btn btn-mini">Cancel</a></form></div></div></div></div><div class="controls"><textarea id="html" rows="15" cols="80" class="content span10 input-xlarge"></textarea><a id="send_button" class="btn btn-primary btn-large">Send !</a></div></div></fieldset></form>');
  }
  else
  {
  buf.push('<div class="well"><p><strong>Hey !</strong></p><p><Before>You\'ll be able to send mail, You need to configure a mailbox.</Before></p><P>It\'s easy - just click <a href="#config-mailboxes">add/modify </a>from the menu.</P></div>');
  }
  }
  return buf.join("");
  };
});
window.require.register("templates/_mail/mail_list", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<td');
  buf.push(attrs({ 'title':(mailboxName), 'style':('width: 5px; padding: 0; background-color: ' + model.getColor() + ';') }, {"title":true,"style":true}));
  buf.push('></td><td');
  buf.push(attrs({ 'title':(model.isFlagged()?'Unstar':'Star'), "class": ('toggleflag') }, {"title":true}));
  buf.push('>');
  if ( model.isFlagged())
  {
  buf.push('<i class="icon-star"></i>');
  }
  else
  {
  buf.push('<i class="icon-star-empty"></i>');
  }
  buf.push('</td><td');
  buf.push(attrs({ 'title':(mailboxName), "class": (model.isRead()?'read':'unread') }, {"title":true,"class":true}));
  buf.push('><h4>' + escape((interp = model.fromShort()) == null ? '' : interp) + '<i class="date">' + escape((interp = model.date()) == null ? '' : interp) + '</i>');
  if ( model.hasAttachments())
  {
  buf.push('<i class="icon-file"></i>');
  }
  buf.push('</h4><p class="subject">' + escape((interp = model.get("subject")) == null ? '' : interp) + '</p></td>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_mail/mail_new", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div style="margin-bottom: 10px; margin-top: 0px;" class="btn-group center"><a id="get_new_mails" class="btn btn-primary btn-large"> Check for new mail</a></div>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_mail/mail_sent", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<p class="well"><strong> Mail sent !</strong></p>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_mailbox/form", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<from class="form-horizontal"><fieldset><legend>Access data</legend><div class="control-group"><label for="name" class="control-label">Title</label><div class="controls"><input');
  buf.push(attrs({ 'id':("name"), 'type':("text"), 'value':(model.get("name")), "class": ('content') + ' ' + ('input-xlarge') }, {"id":true,"type":true,"value":true}));
  buf.push('/><p class="help-block">Name your mailbox to identify it easily.</p></div></div><div class="control-group"><label for="login" class="control-label">Your login</label><div class="controls"><input');
  buf.push(attrs({ 'id':("login"), 'type':("text"), 'value':(model.get("login")), "class": ('content') + ' ' + ('input-xlarge') }, {"id":true,"type":true,"value":true}));
  buf.push('/></div></div><div class="control-group"><label for="password" class="control-label">Your password</label><div class="controls"><input');
  buf.push(attrs({ 'id':("password"), 'type':("password"), 'value':(model.get("password")), "class": ('content') + ' ' + ('input-xlarge') }, {"id":true,"type":true,"value":true}));
  buf.push('/><p class="help-block">Login and password you use for this mailbox. It\'s stored safely, don\'t worry.</p></div></div><div class="control-group"><label for="color" class="control-label">Rainbows and unicorns</label><div class="controls"><select');
  buf.push(attrs({ 'id':("color"), 'selected':(model.get("color")), "class": ('content') + ' ' + ('input-xlarge') }, {"id":true,"selected":true}));
  buf.push('><option');
  buf.push(attrs({ 'value':("orange"), 'selected':("orange" === model.get("color")) }, {"value":true,"selected":true}));
  buf.push('>orange</option><option');
  buf.push(attrs({ 'value':("blue"), 'selected':("blue" === model.get("color")) }, {"value":true,"selected":true}));
  buf.push('>blue</option><option');
  buf.push(attrs({ 'value':("red"), 'selected':("red" === model.get("color")) }, {"value":true,"selected":true}));
  buf.push('>red</option><option');
  buf.push(attrs({ 'value':("green"), 'selected':("green" === model.get("color")) }, {"value":true,"selected":true}));
  buf.push('>green</option><option');
  buf.push(attrs({ 'value':("gold"), 'selected':("gold" === model.get("color")) }, {"value":true,"selected":true}));
  buf.push('>gold</option><option');
  buf.push(attrs({ 'value':("purple"), 'selected':("purple" === model.get("color")) }, {"value":true,"selected":true}));
  buf.push('>purple</option><option');
  buf.push(attrs({ 'value':("pink"), 'selected':("pink" === model.get("color")) }, {"value":true,"selected":true}));
  buf.push('>pink</option><option');
  buf.push(attrs({ 'value':("black"), 'selected':("black" === model.get("color")) }, {"value":true,"selected":true}));
  buf.push('>black</option><option');
  buf.push(attrs({ 'value':("brown"), 'selected':("brown" === model.get("color")) }, {"value":true,"selected":true}));
  buf.push('>brown</option></select><p class="help-block">The color to mark mails from this inbox. Enjoy!</p></div></div></fieldset><fieldset><legend>Server data</legend><div class="control-group"><label for="imapServer" class="control-label">IMAP host</label><div class="controls"><input');
  buf.push(attrs({ 'id':("imapServer"), 'type':("text"), 'value':(model.get("imapServer")), "class": ('content') + ' ' + ('input-xlarge') }, {"id":true,"type":true,"value":true}));
  buf.push('/><p class="help-block">The inbound server address. Say imap.gmail.com ..</p></div></div><div class="control-group"><label for="imapPort" class="control-label">IMAP port</label><div class="controls"><input');
  buf.push(attrs({ 'id':("imapPort"), 'type':("text"), 'value':(model.get("imapPort")), "class": ('content') + ' ' + ('input-xlarge') }, {"id":true,"type":true,"value":true}));
  buf.push('/><p class="help-block">Usually 993.</p></div></div></fieldset><div class="form-actions"><button class="save_mailbox isEdit btn btn-success">save</button><button class="cancel_edit_mailbox isEdit btn btn-warning">cancel</button></div></from>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_mailbox/list", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<p id="no-mailbox-msg">no mailbox found</p><div id="add_mailbox_button_container"><a href="#config/mailboxes/new" id="add_mailbox" class="btn">Add a new mailbox</a></div>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_mailbox/modal", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div class="modal-header"><h3 id="confirm-delete-modal-label">Warning!</h3></div><div class="modal-body"><p>You are about to delete a mailbox and all its mails. Do you\nyou want to continue?</p></div><div class="modal-footer"><button data-dismiss="modal" aria-hidden="true" class="yes-button btn">Yes</button><button data-dismiss="modal" aria-hidden="true" class="no-button btn btn-info">No</button></div>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_mailbox/thumb", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<span');
  buf.push(attrs({ 'style':("background-color: " + (model.get('color')) + ";"), "class": ('badge') }, {"style":true}));
  buf.push('></span><h3>' + escape((interp = model.get('name')) == null ? '' : interp) + '</h3>');
  if ( model.get("statusMsg"))
  {
  buf.push('<span class="mailbox-status"> ' + escape((interp = model.get('statusMsg')) == null ? '' : interp) + '</span>');
  }
  buf.push('<button class="edit-mailbox btn">edit</button><button class="delete-mailbox btn btn-danger">delete</button>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_mailsent/mailsent_big", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div class="well"><p>To: ' + escape((interp = model.to()) == null ? '' : interp) + '');
  if ( model.hasCC())
  {
  buf.push('<p>Cc:  ' + escape((interp = model.cc()) == null ? '' : interp) + '</p>');
  }
  if ( model.hasBCC())
  {
  buf.push('<p>Bcc:  ' + escape((interp = model.bcc()) == null ? '' : interp) + '</p>');
  }
  buf.push('</p><p><i style="color: lightgray;">sent ' + escape((interp = model.date()) == null ? '' : interp) + '</i><br/></p><h3>' + escape((interp = model.get("subject")) == null ? '' : interp) + '</h3><br/><iframe id="mail_content_html" name="mail_content_html">' + ((interp = model.html()) == null ? '' : interp) + '</iframe></div>');
  if ( model.hasAttachments())
  {
  buf.push('<div id="attachments_list" class="well"></div>');
  }
  }
  return buf.join("");
  };
});
window.require.register("templates/_mailsent/mailsent_list", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  if ( visible)
  {
  buf.push('<td');
  buf.push(attrs({ 'style':('width: 5px; padding: 0; background-color: ' + model.getColor() + ';') }, {"style":true}));
  buf.push('></td>');
  if ( active)
  {
  buf.push('<td style="background-color: lightgray; overflow: hidden;"><p><strong>' + escape((interp = model.toShort()) == null ? '' : interp) + '</strong>');
  if ( model.hasAttachments())
  {
  buf.push('<i class="icon-file"></i>');
  }
  buf.push('<br/><i style="color: black;">' + escape((interp = model.date()) == null ? '' : interp) + '</i><p>' + escape((interp = model.get("subject")) == null ? '' : interp) + '</p></p></td>');
  }
  else
  {
  buf.push('<td><p><strong>' + escape((interp = model.toShort()) == null ? '' : interp) + '</strong>');
  if ( model.hasAttachments())
  {
  buf.push('<i class="icon-file"></i>');
  }
  buf.push('<br/><i style="color: gray;">' + escape((interp = model.date()) == null ? '' : interp) + '</i><p>' + escape((interp = model.get("subject")) == null ? '' : interp) + '</p></p></td>');
  }
  }
  }
  return buf.join("");
  };
});
window.require.register("templates/_message/message_error", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div class="alert alert-error"><button type="button" data-dismiss="alert" class="close">x</button><strong>Oh, snap !</strong><p>' + ((interp = model.get("text")) == null ? '' : interp) + '</p></div>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_message/message_info", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div class="alert alert-info"><button type="button" data-dismiss="alert" class="close">x</button><strong>Heads up!</strong><p>' + ((interp = model.get("text")) == null ? '' : interp) + '</p></div>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_message/message_success", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div class="alert alert-success"><button type="button" data-dismiss="alert" class="close">x</button><strong>Well done !</strong><p>' + ((interp = model.get("text")) == null ? '' : interp) + '</p></div>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_message/message_warning", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div class="alert"><button type="button" data-dismiss="alert" class="close">x</button><strong>Warning !</strong><p>' + ((interp = model.get("text")) == null ? '' : interp) + '</p></div>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_message/normal", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<p class="well">Fetching new mail ...</p>');
  }
  return buf.join("");
  };
});
window.require.register("templates/app", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div id="message_box"></div><div class="container-fluid"><div class="row-fluid"><div id="sidebar" class="span1"><div id="menu_container" class="well sidebar-nav"></div></div><div id="content"></div><div id="box-content"></div></div></div>');
  }
  return buf.join("");
  };
});
window.require.register("templates/folders_menu", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<a data-toggle="dropdown" href="#" class="btn dropdown-toggle"><span id="currentfolder">Choose Folder</span><span class="caret"></span></a><ul id="folderlist" class="dropdown-menu pull-right"></ul>');
  }
  return buf.join("");
  };
});
window.require.register("templates/menu", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
  attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<ul class="nav nav-list"><li id="inboxbutton" class="menu_option"><a href="#inbox"><img src="img/icon-mails.png"/></a></li><li id="mailboxesbutton" class="menu_option"><a href="#config/mailboxes"><img src="img/icon-config.png"/></a></li></ul>');
  }
  return buf.join("");
  };
});
window.require.register("views/_old/mails_answer", function(exports, require, module) {
  var Mail, MailNew,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Mail = require("models/mail").Mail;

  MailNew = require("models/mail_new").MailNew;

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
          return $(el).html(require('templates/_mail/mail_sent'));
        },
        error: function() {
          return console.log("error!");
        }
      });
      return console.log("sending mail: " + this.mailtosend);
    };

    MailsAnswer.prototype.setBasic = function(show) {
      if (show == null) {
        show = true;
      }
      if (show) {
        return this.$("#mail_basic").show();
      } else {
        return this.$("#mail_basic").hide();
      }
    };

    MailsAnswer.prototype.setTo = function(show) {
      if (show == null) {
        show = true;
      }
      if (show) {
        return this.$("#mail_to").show();
      } else {
        return this.$("#mail_to").hide();
      }
    };

    MailsAnswer.prototype.setAdvanced = function(show) {
      if (show == null) {
        show = true;
      }
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
      var editor, error, template;
      $(this.el).html("");
      template = require('templates/_mail/mail_answer');
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
      } catch (_error) {
        error = _error;
        console.log(error);
      }
      this.setBasic(true);
      this.setTo(false);
      this.setAdvanced(false);
      return this;
    };

    return MailsAnswer;

  })(Backbone.View);
  
});
window.require.register("views/_old/mails_column", function(exports, require, module) {
  var Mail, MailsList, MailsListMore, MailsListNew,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Mail = require("models/mail").Mail;

  MailsList = require("views/mails_list").MailsList;

  MailsListMore = require("views/mails_list_more").MailsListMore;

  MailsListNew = require("views/mails_list_new").MailsListNew;

  /*
      @file: mails_column.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description:
          The view of the central column - the one which holds the list of mail.
  */


  exports.MailsColumn = (function(_super) {
    __extends(MailsColumn, _super);

    MailsColumn.prototype.id = "mailslist";

    MailsColumn.prototype.className = "mails";

    function MailsColumn(el, collection, mailboxes) {
      this.el = el;
      this.collection = collection;
      this.mailboxes = mailboxes;
      MailsColumn.__super__.constructor.call(this);
    }

    MailsColumn.prototype.render = function() {
      var el;
      this.$el.html(require('templates/_mail/mails'));
      this.viewMailsListNew = new MailsListNew(this.$("#button_get_new_mails"), this.collection);
      this.viewMailsList = new MailsList(this.$("#mails_list_container"), this.collection);
      el = this.$("#button_load_more_mails");
      this.viewMailsListMore = new MailsListMore(el, this.collection, this.mailboxes);
      this.viewMailsListNew.render();
      this.viewMailsList.render();
      this.viewMailsListMore.render();
      return this;
    };

    return MailsColumn;

  })(Backbone.View);
  
});
window.require.register("views/_old/mails_compose", function(exports, require, module) {
  var Mail, MailNew, MailsAnswer,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Mail = require("models/mail").Mail;

  MailsAnswer = require("views/mails_answer").MailsAnswer;

  MailNew = require("models/mail_new").MailNew;

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
          window.app.mailssent.resetAndFetch();
          console.log("sent!");
          $(el).html(require('templates/_mail/mail_sent'));
          return window.app.logmessages.add({
            "type": "success",
            "text": "Message was saved in cozy, and will be sent as soon as possible.",
            "createdAt": new Date().valueOf(),
            "timeout": 5
          });
        },
        error: function() {
          console.log("error!");
          return window.app.logmessages.create({
            "type": "error",
            "text": "Message could not be sent. Check your mailbox settings",
            "createdAt": new Date().valueOf(),
            "timeout": 0
          });
        }
      });
      return console.log("sending mail: " + this.mailtosend);
    };

    MailsCompose.prototype.render = function() {
      var editor, error, template;
      template = require('templates/_mail/mail_compose');
      $(this.el).html(template({
        "models": this.collection.models
      }));
      try {
        return editor = new wysihtml5.Editor("html", {
          toolbar: "wysihtml5-toolbar",
          parserRules: wysihtml5ParserRules,
          stylesheets: ["http://yui.yahooapis.com/2.9.0/build/reset/reset-min.css", "css/editor.css"]
        });
      } catch (_error) {
        error = _error;
        return console.log(error.toString());
      }
    };

    return MailsCompose;

  })(Backbone.View);
  
});
window.require.register("views/_old/mails_list_more", function(exports, require, module) {
  var Mail,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Mail = require("../models/mail").Mail;

  /*
      @file: mails_list_more.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description:
          The view with the "load more" button.
          Also displays info on how many messages are visible in this filer, and
          how many are effectiveley downloaded.
  */


  exports.MailsListMore = (function(_super) {
    __extends(MailsListMore, _super);

    MailsListMore.prototype.clickable = true;

    MailsListMore.prototype.disabled = false;

    function MailsListMore(el, collection, mailboxes) {
      this.el = el;
      this.collection = collection;
      this.mailboxes = mailboxes;
      MailsListMore.__super__.constructor.call(this);
    }

    MailsListMore.prototype.initialize = function() {
      this.collection.on('reset', this.render, this);
      this.collection.on('add', this.render, this);
      this.collection.on('updated_number_mails_shown', this.render, this);
      return this.mailboxes.on("change_active_mailboxes", this.render, this);
    };

    MailsListMore.prototype.events = {
      "click #add_more_mails": 'loadOlderMails'
    };

    MailsListMore.prototype.loadOlderMails = function() {
      var button, element, error, success,
        _this = this;
      button = this.$("#add_more_mails");
      button.addClass("disabled");
      button.text("Loading...");
      if (this.clickable) {
        success = function(nbMails) {
          button.text("more messages");
          if (nbMails === 0) {
            return $(_this.el).hide();
          }
        };
        error = function(collection, error) {
          button.text("more messages");
          _this.disabled = true;
          return _this.render();
        };
        this.collection.fetchOlder(success, error);
        this.clickable = false;
        element = this;
        return setTimeout(function() {
          element.clickable = true;
          return element.render();
        }, 1000 * 7);
      }
    };

    MailsListMore.prototype.render = function() {
      var template;
      this.clickable = true;
      template = require("./templates/_mail/mails_more");
      $(this.el).html(template({
        collection: this.collection,
        disabled: this.disabled
      }));
      return this;
    };

    return MailsListMore;

  })(Backbone.View);
  
});
window.require.register("views/_old/mails_list_new", function(exports, require, module) {
  var Mail,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Mail = require("models/mail").Mail;

  /*
      @file: mails_list_new.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description:
          The view with the "load new" button.
  */


  exports.MailsListNew = (function(_super) {
    __extends(MailsListNew, _super);

    MailsListNew.prototype.clickable = true;

    function MailsListNew(el, collection) {
      this.el = el;
      this.collection = collection;
      MailsListNew.__super__.constructor.call(this);
    }

    MailsListNew.prototype.initialize = function() {
      var _this = this;
      this.collection.on('reset', this.render, this);
      return Backbone.Mediator.subscribe('mails:fetched', function(date) {
        return _this.changeGetNewMailLabel(date);
      });
    };

    MailsListNew.prototype.events = {
      "click #get_new_mails": 'loadNewMails'
    };

    MailsListNew.prototype.loadNewMails = function() {
      var element,
        _this = this;
      element = this;
      if (this.clickable) {
        this.clickable = false;
        this.$("#get_new_mails").addClass("disabled").text("Checking for new mail...");
        this.collection.fetchNew(function(err) {
          var date;
          if (err) {
            alert("An error occured while fetching mails.");
          }
          element.clickable = true;
          date = new Date();
          return _this.changeGetNewMailLabel(date);
        });
        return setTimeout(function() {
          element.clickable = true;
          return this.$("#get_new_mails").removeClass("disabled");
        }, 1000 * 4);
      }
    };

    MailsListNew.prototype.changeGetNewMailLabel = function(date) {
      var dateString, msg;
      dateString = date.getHours() + ":";
      if (date.getMinutes() < 10) {
        dateString += "0" + date.getMinutes();
      } else {
        dateString += date.getMinutes();
      }
      this.$("#get_new_mails").removeClass("disabled");
      msg = "Check for new mail (Last check at " + dateString + ")";
      return this.$("#get_new_mails").text(msg);
    };

    MailsListNew.prototype.render = function() {
      var template;
      this.clickable = true;
      template = require("templates/_mail/mail_new");
      this.$el.html(template({
        collection: this.collection
      }));
      return this;
    };

    return MailsListNew;

  })(Backbone.View);
  
});
window.require.register("views/_old/mailssent_column", function(exports, require, module) {
  var MailsSentList, MailsSentListMore,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  MailsSentList = require("views/mailssent_list").MailsSentList;

  MailsSentListMore = require("views/mailssent_list_more").MailsSentListMore;

  /*
    @file: mailssent_column.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
      The view of the central column - the one which holds the list of mail.
  */


  exports.MailsSentColumn = (function(_super) {
    __extends(MailsSentColumn, _super);

    MailsSentColumn.prototype.id = "mailssentlist";

    MailsSentColumn.prototype.className = "mails";

    function MailsSentColumn(el, collection) {
      this.el = el;
      this.collection = collection;
      MailsSentColumn.__super__.constructor.call(this);
    }

    MailsSentColumn.prototype.render = function() {
      $(this.el).html(require('templates/_mail/mails'));
      this.viewMailsSentList = new MailsSentList(this.$("#mails_list_container"), this.collection);
      this.viewMailsSentListMore = new MailsSentListMore(this.$("#button_load_more_mails"), this.collection);
      this.viewMailsSentList.render();
      this.viewMailsSentListMore.render();
      return this;
    };

    return MailsSentColumn;

  })(Backbone.View);
  
});
window.require.register("views/_old/mailssent_element", function(exports, require, module) {
  var MailSent, MailsAttachmentsList,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  MailSent = require("models/mail_sent").MailSent;

  MailsAttachmentsList = require("views/mails_attachments_list").MailsAttachmentsList;

  /*
    @file: mailssent_element.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
      The mail view. Displays all data & options.
      Also, handles buttons.
  */


  exports.MailsSentElement = (function(_super) {
    __extends(MailsSentElement, _super);

    function MailsSentElement(el, collection) {
      this.el = el;
      this.collection = collection;
      MailsSentElement.__super__.constructor.call(this);
      this.collection.on("change_active_mail", this.render, this);
    }

    MailsSentElement.prototype.render = function() {
      var template,
        _this = this;
      $(this.el).html("");
      if (this.collection.activeMail != null) {
        template = require('templates/_mailsent/mailsent_big');
        $(this.el).html(template({
          "model": this.collection.activeMail
        }));
        if (this.collection.activeMail.hasHtml()) {
          setTimeout(function() {
            $("#mail_content_html").contents().find("html").html(_this.collection.activeMail.html());
            $("#mail_content_html").contents().find("head").append('<link rel="stylesheet" href="css/reset_bootstrap.css">');
            $("#mail_content_html").contents().find("head").append('<base target="_blank">');
            $("#mail_content_html").height($("#mail_content_html").contents().find("html").height());
            if ($("#mail_content_html").contents().find("html").height() > 600) {
              return $("#additional_bar").show();
            }
          }, 50);
          setTimeout(function() {
            return $("#mail_content_html").height($("#mail_content_html").contents().find("html").height());
          }, 1000);
        }
        if (this.collection.activeMail.get("hasAttachments")) {
          window.app.viewAttachments = new MailsAttachmentsList($("#attachments_list"), this.collection.activeMail);
        }
      }
      return this;
    };

    return MailsSentElement;

  })(Backbone.View);
  
});
window.require.register("views/_old/mailssent_list", function(exports, require, module) {
  var MailsSentListElement,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  MailsSentListElement = require("./mailssent_list_element").MailsSentListElement;

  /*
    @file: mailssent_list.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description: 
      View to generate the list of sent mails - the second column from the left.
      Uses MailsListElement to generate each mail's view
  */


  exports.MailsSentList = (function(_super) {
    __extends(MailsSentList, _super);

    MailsSentList.prototype.id = "mailssent_list";

    function MailsSentList(el, collection) {
      this.el = el;
      this.collection = collection;
      MailsSentList.__super__.constructor.call(this);
      this.collection.view = this;
    }

    MailsSentList.prototype.initialize = function() {
      this.collection.on('reset', this.render, this);
      return this.collection.on("add", this.addOne, this);
    };

    MailsSentList.prototype.addOne = function(mail) {
      var box;
      if (Number(mail.get("createdAt")) < this.collection.timestampOld) {
        this.collection.timestampOld = Number(mail.get("createdAt"));
        this.collection.lastIdOld = mail.get("id");
      }
      box = new MailsSentListElement(mail, this.collection);
      return $(this.el).append(box.render().el);
    };

    MailsSentList.prototype.render = function() {
      var col,
        _this = this;
      $(this.el).html("");
      col = this.collection;
      this.collection.each(function(m) {
        return _this.addOne(m);
      });
      return this;
    };

    return MailsSentList;

  })(Backbone.View);
  
});
window.require.register("views/_old/mailssent_list_element", function(exports, require, module) {
  var MailSent,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  MailSent = require("models/mail_sent").MailSent;

  /*
    @file: mailssent_list_element.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
      The element on the list of mails. Reacts for events, and stuff.
  */


  exports.MailsSentListElement = (function(_super) {
    __extends(MailsSentListElement, _super);

    MailsSentListElement.prototype.tagName = "tr";

    MailsSentListElement.prototype.active = false;

    MailsSentListElement.prototype.visible = true;

    MailsSentListElement.prototype.events = {
      "click": "setActiveMail"
    };

    function MailsSentListElement(model, collection) {
      this.model = model;
      this.collection = collection;
      MailsSentListElement.__super__.constructor.call(this);
      this.model.view = this;
      window.app.mailboxes.on("change_active_mailboxes", this.checkVisible, this);
    }

    MailsSentListElement.prototype.setActiveMail = function(event) {
      var _ref, _ref1, _ref2, _ref3;
      if ((_ref = this.collection.activeMail) != null) {
        if ((_ref1 = _ref.view) != null) {
          _ref1.active = false;
        }
      }
      if ((_ref2 = this.collection.activeMail) != null) {
        if ((_ref3 = _ref2.view) != null) {
          _ref3.render();
        }
      }
      this.collection.activeMail = this.model;
      this.collection.activeMail.view.active = true;
      this.render();
      return this.collection.trigger("change_active_mail");
    };

    MailsSentListElement.prototype.checkVisible = function() {
      var state, _ref;
      state = (_ref = this.model.get("mailbox"), __indexOf.call(window.app.mailboxes.activeMailboxes, _ref) >= 0);
      if (state !== this.visible) {
        this.visible = state;
        return this.render();
      }
    };

    MailsSentListElement.prototype.render = function() {
      var template, _ref;
      this.visible = (_ref = this.model.get("mailbox"), __indexOf.call(window.app.mailboxes.activeMailboxes, _ref) >= 0);
      template = require('templates/_mailsent/mailsent_list');
      $(this.el).html(template({
        "model": this.model,
        "active": this.active,
        "visible": this.visible
      }));
      return this;
    };

    return MailsSentListElement;

  })(Backbone.View);
  
});
window.require.register("views/_old/mailssent_list_more", function(exports, require, module) {
  var MailSent,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  MailSent = require("models/mail_sent").MailSent;

  /*
    @file: mailssent_list_more.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
      The view with the "load more" button.
      Also displays info on how many messages are visible in this filer, and how many are effectiveley downloaded.
  */


  exports.MailsSentListMore = (function(_super) {
    __extends(MailsSentListMore, _super);

    MailsSentListMore.prototype.clickable = true;

    MailsSentListMore.prototype.disabled = false;

    function MailsSentListMore(el, collection) {
      this.el = el;
      this.collection = collection;
      MailsSentListMore.__super__.constructor.call(this);
    }

    MailsSentListMore.prototype.initialize = function() {
      this.collection.on('reset', this.render, this);
      this.collection.on('add', this.render, this);
      this.collection.on('updated_number_mails_shown', this.render, this);
      return window.app.mailboxes.on("change_active_mailboxes", this.render, this);
    };

    MailsSentListMore.prototype.events = {
      "click #add_more_mails": 'loadOlderMails'
    };

    MailsSentListMore.prototype.loadOlderMails = function() {
      var element, error, success,
        _this = this;
      $("#add_more_mails").addClass("disabled");
      if (this.clickable) {
        success = function(collection) {
          return window.app.mailssent.trigger("update_number_mails_shown");
        };
        error = function(collection, error) {
          if (error.status === 499) {
            _this.disabled = true;
            return _this.render();
          }
        };
        this.collection.fetchOlder(success, error);
        this.clickable = false;
        element = this;
        return setTimeout(function() {
          element.clickable = true;
          element.render();
          return console.log("retry");
        }, 1000 * 7);
      }
    };

    MailsSentListMore.prototype.render = function() {
      var template;
      this.clickable = true;
      template = require("./templates/_mail/mails_more");
      $(this.el).html(template({
        "collection": this.collection,
        "disabled": this.disabled
      }));
      return this;
    };

    return MailsSentListMore;

  })(Backbone.View);
  
});
window.require.register("views/_old/menu_mailboxes_list", function(exports, require, module) {
  var MenuMailboxListElement,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

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
      var box, mailbox, _i, _len, _ref;
      this.$el = $("#menu_mailboxes");
      this.$el.html("");
      this.total_inbox = 0;
      _ref = this.collection.toArray();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        mailbox = _ref[_i];
        box = new MenuMailboxListElement(mailbox, this.collection);
        box.render();
        this.$el.append(box.el);
        this.total_inbox += Number(mailbox.get("new_messages"));
      }
      return this;
    };

    MenuMailboxesList.prototype.showLoading = function() {
      this.$el.html('loading...');
      return this.$el.spin('tiny');
    };

    MenuMailboxesList.prototype.hideLoading = function() {
      return this.$el.spin();
    };

    return MenuMailboxesList;

  })(Backbone.View);
  
});
window.require.register("views/_old/menu_mailboxes_list_element", function(exports, require, module) {
  /*
      @file: menu_mailboxes_list_element.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description:
          The element of the list of mailboxes in the leftmost column - the menu.
  */

  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  exports.MenuMailboxListElement = (function(_super) {
    __extends(MenuMailboxListElement, _super);

    MenuMailboxListElement.prototype.tagName = 'li';

    function MenuMailboxListElement(model, collection) {
      this.model = model;
      this.collection = collection;
      MenuMailboxListElement.__super__.constructor.call(this);
    }

    MenuMailboxListElement.prototype.events = {
      'click a.menu_choose': 'setupMailbox'
    };

    MenuMailboxListElement.prototype.setupMailbox = function(event) {
      this.model.set('checked', !this.model.get('checked'));
      this.model.save();
      return this.collection.updateActiveMailboxes();
    };

    MenuMailboxListElement.prototype.render = function() {
      var template;
      template = require('templates/_mailbox/mailbox_menu');
      this.$el.html(template({
        model: this.model.toJSON()
      }));
      return this;
    };

    return MenuMailboxListElement;

  })(Backbone.View);
  
});
window.require.register("views/app", function(exports, require, module) {
  var MailboxCollection, MailboxesList, MailsCollection, MailsList, Menu, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  MailsCollection = require('collections/mails').MailsCollection;

  MailboxCollection = require('collections/mailboxes').MailboxCollection;

  MailboxesList = require('views/mailboxes_list').MailboxesList;

  MailsList = require('views/mails_list').MailsList;

  Menu = require('views/menu').Menu;

  /*
      @file: app.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description:
          The application's main view - creates other views, lays things out.
  */


  exports.AppView = (function(_super) {
    __extends(AppView, _super);

    function AppView() {
      _ref = AppView.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    AppView.prototype.el = 'body';

    AppView.prototype.initialize = function() {
      var _this = this;
      this.views = {};
      this.mails = new MailsCollection();
      this.mailboxes = new MailboxCollection();
      this.mailboxes.fetch({
        success: function() {
          return _this.views.mailboxList.render();
        },
        error: function() {
          return alert("Error while loading mailboxes");
        }
      });
      this.views.menu = new Menu();
      this.views.menu.render().$el.appendTo($('body'));
      this.views.mailboxList = new MailboxesList({
        collection: this.mailboxes
      });
      this.views.mailboxList.render().$el.hide().appendTo($('body'));
      this.views.mailList = new MailsList({
        collection: this.mails
      });
      return this.views.mailList.render().$el.hide().appendTo($('body'));
    };

    return AppView;

  })(Backbone.View);
  
});
window.require.register("views/folders_menu", function(exports, require, module) {
  var FolderMenu, ViewCollection, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  ViewCollection = require('lib/view_collection');

  /*
      @file: mailboxes_list.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description:
          Displays the list of configured mailboxes.
  */


  module.exports = FolderMenu = (function(_super) {
    __extends(FolderMenu, _super);

    function FolderMenu() {
      _ref = FolderMenu.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    FolderMenu.prototype.id = "folders-menu";

    FolderMenu.prototype.tagName = "div";

    FolderMenu.prototype.className = "btn-group";

    FolderMenu.prototype.itemView = require('views/folders_menu_element');

    FolderMenu.prototype.template = require('templates/folders_menu');

    FolderMenu.prototype.appendView = function(view) {
      return this.$('#folderlist').append(view.$el);
    };

    return FolderMenu;

  })(ViewCollection);
  
});
window.require.register("views/folders_menu_element", function(exports, require, module) {
  var BaseView, FolderMenuElement, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  BaseView = require('lib/base_view');

  module.exports = FolderMenuElement = (function(_super) {
    __extends(FolderMenuElement, _super);

    function FolderMenuElement() {
      _ref = FolderMenuElement.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    FolderMenuElement.prototype.tagName = 'li';

    FolderMenuElement.prototype.template = function(attributes) {
      var id, name;
      id = attributes.id, name = attributes.name;
      return "<a href=\"#folder/" + id + "\"> " + name + " </a>";
    };

    FolderMenuElement.prototype.getRenderData = function() {
      return this.model.toJSON();
    };

    return FolderMenuElement;

  })(BaseView);
  
});
window.require.register("views/mail", function(exports, require, module) {
  var BaseView, Mail, MailAttachmentsList, _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Mail = require("models/mail").Mail;

  MailAttachmentsList = require("views/mail_attachments_list").MailAttachmentsList;

  BaseView = require('lib/base_view');

  /*
      @file: mails_element.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description:
          The mail view. Displays all data & options.
          Also, handles buttons.
  */


  exports.MailView = (function(_super) {
    __extends(MailView, _super);

    function MailView() {
      this.remove = __bind(this.remove, this);
      this.afterRender = __bind(this.afterRender, this);
      _ref = MailView.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    MailView.prototype.id = 'mail';

    MailView.prototype.events = {
      "click #btn-read": 'buttonUnread',
      "click #btn-flagged": 'buttonFlagged',
      "click #btn-delete": 'buttonDelete'
    };

    MailView.prototype.template = require('templates/_mail/big');

    MailView.prototype.getRenderData = function() {
      return {
        model: this.model
      };
    };

    MailView.prototype.initialize = function() {
      console.log(this.model.get('_attachments'));
      return this.attachmentsView = new MailAttachmentsList({
        model: this.model
      });
    };

    MailView.prototype.afterRender = function() {
      var _ref1,
        _this = this;
      if (this.model.hasHtml()) {
        this.timeout1 = setTimeout(function() {
          var basetarget, csslink;
          _this.timeout1 = null;
          _this.iframe = _this.$("#mail_content_html");
          _this.iframehtml = _this.iframe.contents().find("html");
          csslink = '<link rel="stylesheet" href="css/reset_bootstrap.css">';
          basetarget = '<base target="_blank">';
          _this.iframehtml.html(_this.model.html());
          _this.iframehtml.find('head').append(csslink);
          _this.iframehtml.find('head').append(basetarget);
          _this.iframe.height(_this.iframehtml.height());
          if (_this.iframehtml.height() > 600) {
            return $("#additional_bar").hide();
          }
        }, 50);
        this.timeout2 = setTimeout(function() {
          _this.timeout2 = null;
          _this.iframe = _this.$("#mail_content_html");
          console.log;
          return _this.iframe.height(_this.iframehtml.height());
        }, 1000);
      }
      if (this.model.get("hasAttachments")) {
        if ((_ref1 = this.attachmentsView) != null) {
          _ref1.render().$el.appendTo(this.$el);
        }
      }
      return this.$el.niceScroll();
    };

    MailView.prototype.remove = function() {
      this.$el.getNiceScroll().remove();
      MailView.__super__.remove.apply(this, arguments);
      if (this.timeout1) {
        clearTimeout(this.timeout1);
      }
      if (this.timeout2) {
        return clearTimeout(this.timeout2);
      }
    };

    /*
            CLICK ACTIONS
    */


    MailView.prototype.createAnswerView = function() {
      if (!window.app.viewAnswer) {
        console.log("create new answer view");
        window.app.viewAnswer = new MailsAnswer(this.$("#answer_form"), this.model, window.app.mailtosend);
        return window.app.viewAnswer.render();
      }
    };

    MailView.prototype.scrollDown = function() {
      return setTimeout(function() {
        return $("#column_mail").animate({
          scrollTop: 2 * $("#column_mail").outerHeight(true)
        }, 750);
      }, 250);
    };

    MailView.prototype.buttonUnread = function() {
      this.model.markRead(!this.model.isRead());
      return this.model.save();
    };

    MailView.prototype.buttonFlagged = function() {
      this.model.markFlagged(!this.model.isFlagged());
      return this.model.save();
    };

    MailView.prototype.buttonDelete = function() {
      return this.model.destroy();
    };

    return MailView;

  })(BaseView);
  
});
window.require.register("views/mail_attachments_list", function(exports, require, module) {
  var MailAttachmentsListElement, ViewCollection,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  MailAttachmentsListElement = require("views/mail_attachments_list_element").MailAttachmentsListElement;

  ViewCollection = require('lib/view_collection');

  /*
      @file: mails_attachments_list.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description:
          The list of attachments, created every time user displays a mail.
  */


  exports.MailAttachmentsList = (function(_super) {
    __extends(MailAttachmentsList, _super);

    MailAttachmentsList.prototype.itemView = MailAttachmentsListElement;

    MailAttachmentsList.prototype.template = require('templates/_mail/attachments');

    MailAttachmentsList.prototype.className = 'attachments-box';

    function MailAttachmentsList(options) {
      var attachments, attachmentsarr, key, value;
      attachments = options.model.get('_attachments');
      attachmentsarr = [];
      for (key in attachments) {
        value = attachments[key];
        value['fileName'] = key;
        attachmentsarr.push(value);
      }
      this.collection = new Backbone.Collection(attachmentsarr);
      MailAttachmentsList.__super__.constructor.apply(this, arguments);
    }

    MailAttachmentsList.prototype.initialize = function() {
      MailAttachmentsList.__super__.initialize.apply(this, arguments);
      return this.listenTo(this.collection, {
        'request': this.spin,
        'sync': this.spin
      });
    };

    MailAttachmentsList.prototype.itemViewOptions = function() {
      return {
        mail: this.model
      };
    };

    MailAttachmentsList.prototype.spin = function() {
      return this.$el.spin("small");
    };

    return MailAttachmentsList;

  })(ViewCollection);
  
});
window.require.register("views/mail_attachments_list_element", function(exports, require, module) {
  /*
      @file: mails_attachments_list_element.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description:
          Renders clickable attachments link.
  */

  var BaseView, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  BaseView = require('lib/base_view');

  exports.MailAttachmentsListElement = (function(_super) {
    __extends(MailAttachmentsListElement, _super);

    function MailAttachmentsListElement() {
      _ref = MailAttachmentsListElement.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    MailAttachmentsListElement.prototype.id = 'attachments_list';

    MailAttachmentsListElement.prototype.template = require('templates/_attachment/attachment_element');

    MailAttachmentsListElement.prototype.getRenderData = function() {
      return {
        attachment: this.model,
        href: "mails/" + this.options.mail.get("id") + "/attachments/" + this.model.get("fileName")
      };
    };

    return MailAttachmentsListElement;

  })(BaseView);
  
});
window.require.register("views/mailboxes_list", function(exports, require, module) {
  var Mailbox, ViewCollection, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Mailbox = require("models/mailbox").Mailbox;

  ViewCollection = require('lib/view_collection');

  /*
      @file: mailboxes_list.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description:
          Displays the list of configured mailboxes.
  */


  exports.MailboxesList = (function(_super) {
    __extends(MailboxesList, _super);

    function MailboxesList() {
      _ref = MailboxesList.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    MailboxesList.prototype.id = "mailboxes";

    MailboxesList.prototype.itemView = require('views/mailboxes_list_element');

    MailboxesList.prototype.template = require('templates/_mailbox/list');

    MailboxesList.prototype.checkIfEmpty = function() {
      MailboxesList.__super__.checkIfEmpty.apply(this, arguments);
      return this.$('#no-mailbox-msg').toggle(_.size(this.views) === 0);
    };

    MailboxesList.prototype.appendView = function(view) {
      return this.$el.prepend(view.$el);
    };

    MailboxesList.prototype.afterRender = function() {
      MailboxesList.__super__.afterRender.apply(this, arguments);
      return this.$el.niceScroll();
    };

    MailboxesList.prototype.activate = function(id) {
      var cid, view, _ref1, _results;
      _ref1 = this.views;
      _results = [];
      for (cid in _ref1) {
        view = _ref1[cid];
        if (view.model.id === id) {
          _results.push(view.$el.addClass('active'));
        } else {
          _results.push(view.$el.removeClass('active'));
        }
      }
      return _results;
    };

    return MailboxesList;

  })(ViewCollection);
  
});
window.require.register("views/mailboxes_list_element", function(exports, require, module) {
  /*
      @file: mailboxes_list_element.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description:
          The element of the list of mailboxes.
          mailboxes_list -> mailboxes_list_element
  */

  var BaseView, MailboxesListElement, _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  BaseView = require('lib/base_view');

  module.exports = MailboxesListElement = (function(_super) {
    __extends(MailboxesListElement, _super);

    function MailboxesListElement() {
      this.buttonDelete = __bind(this.buttonDelete, this);
      this.buttonEdit = __bind(this.buttonEdit, this);
      _ref = MailboxesListElement.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    MailboxesListElement.prototype.className = "mailbox_well well";

    MailboxesListElement.prototype.template = require('templates/_mailbox/thumb');

    MailboxesListElement.prototype.isEdit = false;

    MailboxesListElement.prototype.events = {
      "click .edit-mailbox": "buttonEdit",
      "click .delete-mailbox": "buttonDelete"
    };

    MailboxesListElement.prototype.initialize = function() {
      MailboxesListElement.__super__.initialize.apply(this, arguments);
      return this.listenTo(this.model, 'change', this.render);
    };

    MailboxesListElement.prototype.buttonEdit = function(event) {
      return app.router.navigate("config/mailboxes/" + this.model.id, true);
    };

    MailboxesListElement.prototype.buttonDelete = function(event) {
      var _this = this;
      return app.views.modal.showAndThen(function() {
        $(event.target).addClass("disabled");
        return _this.model.destroy({
          error: function(model, xhr) {
            var data, msg;
            msg = "Server error occured";
            if (xhr.status === 400) {
              data = JSON.parse(xhr.responseText);
              msg = data.error;
            }
            alert(msg);
            return $(event.target).removeClass("disabled");
          }
        });
      });
    };

    return MailboxesListElement;

  })(BaseView);
  
});
window.require.register("views/mailboxes_list_form", function(exports, require, module) {
  var BaseView, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  BaseView = require('lib/base_view');

  exports.MailboxForm = (function(_super) {
    __extends(MailboxForm, _super);

    function MailboxForm() {
      _ref = MailboxForm.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    MailboxForm.prototype.id = "mailbox-form";

    MailboxForm.prototype.template = require('templates/_mailbox/form');

    MailboxForm.prototype.events = {
      "click .cancel_edit_mailbox": "buttonCancel",
      "click .save_mailbox": "buttonSave"
    };

    MailboxForm.prototype.initialize = function() {
      MailboxForm.__super__.initialize.apply(this, arguments);
      return this.listenTo(this.model, 'destroy', this.buttonCancel);
    };

    MailboxForm.prototype.getRenderData = function() {
      return {
        model: this.model
      };
    };

    MailboxForm.prototype.afterRender = function() {
      return this.$el.niceScroll();
    };

    MailboxForm.prototype.buttonCancel = function(event) {
      return app.router.navigate('config/mailboxes', true);
    };

    MailboxForm.prototype.buttonSave = function(event) {
      var data, input,
        _this = this;
      if ($(event.target).hasClass("disabled")) {
        return false;
      }
      $(event.target).addClass("disabled").removeClass("buttonSave");
      input = this.$(".content");
      data = {
        name: this.$('#name').val(),
        color: this.$('#color').val()
      };
      input.each(function(i) {
        return data[input[i].id] = input[i].value;
      });
      this.model.isEdit = false;
      return this.model.save(data, {
        success: function() {
          $("#add_mailbox").show();
          $("#no-mailbox-msg").hide();
          window.app.views.mailList.updateColors();
          return _this.render();
        },
        error: function(model, xhr) {
          var msg;
          msg = "Server error occured";
          if (xhr.status === 400) {
            data = JSON.parse(xhr.responseText);
            msg = data.error;
          }
          alert(msg);
          return $(event.target).removeClass("disabled").addClass("buttonSave");
        }
      });
    };

    return MailboxForm;

  })(BaseView);
  
});
window.require.register("views/mails_list", function(exports, require, module) {
  var FolderMenu, ViewCollection, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  ViewCollection = require('lib/view_collection');

  FolderMenu = require('views/folders_menu');

  /*
      @file: mails_list.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description:
          View to generate the list of mails - the second column from the left.
          Uses MailsListElement to generate each mail's view
  */


  exports.MailsList = (function(_super) {
    __extends(MailsList, _super);

    function MailsList() {
      _ref = MailsList.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    MailsList.prototype.id = "mails_list";

    MailsList.prototype.itemView = require("views/mails_list_element").MailsListElement;

    MailsList.prototype.template = require("templates/_mail/list");

    MailsList.prototype.events = {
      "click #add_more_mails": 'loadOlderMails',
      'click #refresh-btn': 'refresh',
      'click #markallread-btn': 'markAllRead'
    };

    MailsList.prototype.initialize = function() {
      MailsList.__super__.initialize.apply(this, arguments);
      this.listenTo(window.app.mailboxes, 'change:color', this.updateColors);
      this.listenTo(window.app.mailboxes, 'add', this.updateColors);
      this.foldermenu = new FolderMenu({
        collection: app.folders
      });
      return this.foldermenu.render();
    };

    MailsList.prototype.checkIfEmpty = function() {
      var empty, _ref1;
      MailsList.__super__.checkIfEmpty.apply(this, arguments);
      empty = _.size(this.views) === 0;
      if ((_ref1 = this.noMailMsg) != null) {
        _ref1.toggle(empty);
      }
      this.$('#markallread-btn').toggle(!empty);
      this.$('#add_more_mails').toggle(!empty);
      return this.$('#refresh-btn').toggle(!empty);
    };

    MailsList.prototype.afterRender = function() {
      this.noMailMsg = this.$('#no-mails-message');
      this.loadmoreBtn = this.$('#add_more_mails');
      this.container = this.$('#mails_list_container');
      this.$('#topbar').append(this.foldermenu.$el);
      if (this.activated) {
        this.activate(this.activated);
      }
      this.$el.niceScroll();
      return MailsList.__super__.afterRender.apply(this, arguments);
    };

    MailsList.prototype.remove = function() {
      this.$el.getNiceScroll().remove();
      return MailsList.__super__.remove.apply(this, arguments);
    };

    MailsList.prototype.appendView = function(view) {
      var dateValueOf;
      if (!this.container) {
        return;
      }
      dateValueOf = view.model.get('dateValueOf');
      if (dateValueOf < this.collection.timestampNew) {
        if (dateValueOf < this.collection.timestampOld) {
          this.collection.timestampOld = dateValueOf;
          this.collection.lastIdOld = view.model.id;
        }
        return this.container.append(view.$el);
      } else {
        if (dateValueOf >= this.collection.timestampNew) {
          this.collection.timestampNew = dateValueOf;
          this.collection.lastIdNew = view.model.id;
        }
        return this.container.prepend(view.$el);
      }
    };

    MailsList.prototype.refresh = function() {
      var btn, promise,
        _this = this;
      btn = this.$('#refresh-btn');
      btn.spin().addClass('disabled');
      promise = $.ajax('mails/fetch-new/');
      promise.error(function(jqXHR, error) {
        btn.text('Connection Error').addClass('error');
        return alert(error);
      });
      promise.success(function() {
        return setTimeout(_this.refresh, 30 * 1000);
      });
      return promise.always(function() {
        return btn.spin().removeClass('disabled');
      });
    };

    MailsList.prototype.markAllRead = function() {
      return this.collection.each(function(model) {
        if (!model.isRead()) {
          model.markRead();
          return model.save();
        }
      });
    };

    MailsList.prototype.loadOlderMails = function() {
      var oldlength,
        _this = this;
      if (!this.loadmoreBtn.hasClass('disabled')) {
        this.loadmoreBtn.addClass("disabled").text("Loading...");
        oldlength = this.collection.length;
        return this.collection.fetchOlder({
          success: function(collection) {
            _this.loadmoreBtn.removeClass('disabled').text("more messages");
            if (_this.collection.length === oldlength) {
              return _this.loadmoreBtn.hide();
            }
          },
          error: function(collection, error) {
            _this.loadmoreBtn.removeClass('disabled').text("more messages");
            return console.log(error);
          }
        });
      }
    };

    MailsList.prototype.updateColors = function() {
      var id, view, _ref1, _results;
      _ref1 = this.views;
      _results = [];
      for (id in _ref1) {
        view = _ref1[id];
        _results.push(view.render());
      }
      return _results;
    };

    MailsList.prototype.activate = function(id) {
      var cid, view, _ref1, _results;
      this.activated = id;
      _ref1 = this.views;
      _results = [];
      for (cid in _ref1) {
        view = _ref1[cid];
        if (view.model.id === id) {
          _results.push(view.$el.addClass('active'));
        } else {
          _results.push(view.$el.removeClass('active'));
        }
      }
      return _results;
    };

    return MailsList;

  })(ViewCollection);
  
});
window.require.register("views/mails_list_element", function(exports, require, module) {
  /*
      @file: mails_list_element.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description:
          The element on the list of mails. Reacts for events, and stuff.
  */

  var _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  exports.MailsListElement = (function(_super) {
    __extends(MailsListElement, _super);

    function MailsListElement() {
      _ref = MailsListElement.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    MailsListElement.prototype.tagName = "tr";

    MailsListElement.prototype.className = 'mailslist-element';

    MailsListElement.prototype.active = false;

    MailsListElement.prototype.visible = true;

    MailsListElement.prototype.events = {
      "click": "setActiveMail",
      "click .toggleflag": 'toggleFlag'
    };

    MailsListElement.prototype.initialize = function() {
      MailsListElement.__super__.initialize.apply(this, arguments);
      this.collection = this.model.collection;
      return this.listenTo(this.model, 'change', this.render);
    };

    MailsListElement.prototype.setActiveMail = function(event) {
      $(".table tr").removeClass("active");
      this.$el.addClass("active");
      if (!this.model.isRead()) {
        this.model.markRead();
        this.model.save();
      }
      return window.app.router.navigate("mail/" + (this.model.get('id')), true);
    };

    MailsListElement.prototype.toggleFlag = function(event) {
      event.preventDefault();
      event.stopPropagation();
      this.model.markFlagged(!this.model.isFlagged());
      return this.model.save({}, {
        ignoreMySocketNotification: true
      });
    };

    MailsListElement.prototype.checkVisible = function() {
      return this.render();
    };

    MailsListElement.prototype.render = function() {
      var data, mailboxname, template, _ref1;
      mailboxname = ((_ref1 = this.model.getMailbox()) != null ? _ref1.get('name') : void 0) || '';
      data = {
        model: this.model,
        mailboxName: mailboxname
      };
      template = require('templates/_mail/mail_list');
      this.$el.html(template(data));
      return this;
    };

    return MailsListElement;

  })(Backbone.View);
  
});
window.require.register("views/mails_list_more", function(exports, require, module) {
  var Mail,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Mail = require("models/mail").Mail;

  /*
      @file: mails_list_more.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description:
          The view with the "load more" button.
          Also displays info on how many messages are visible in this filer, and
          how many are effectiveley downloaded.
  */


  exports.MailsListMore = (function(_super) {
    __extends(MailsListMore, _super);

    MailsListMore.prototype.clickable = true;

    MailsListMore.prototype.disabled = false;

    function MailsListMore(el, collection, mailboxes) {
      this.el = el;
      this.collection = collection;
      this.mailboxes = mailboxes;
      MailsListMore.__super__.constructor.call(this);
    }

    MailsListMore.prototype.initialize = function() {
      this.collection.on('reset', this.render, this);
      this.collection.on('add', this.render, this);
      this.collection.on('updated_number_mails_shown', this.render, this);
      return this.mailboxes.on("change_active_mailboxes", this.render, this);
    };

    MailsListMore.prototype.events = {
      "click #add_more_mails": 'loadOlderMails'
    };

    MailsListMore.prototype.loadOlderMails = function() {
      var button, element, error, success,
        _this = this;
      button = this.$("#add_more_mails");
      button.addClass("disabled");
      button.text("Loading...");
      if (this.clickable) {
        success = function(nbMails) {
          button.text("more messages");
          if (nbMails === 0) {
            return $(_this.el).hide();
          }
        };
        error = function(collection, error) {
          button.text("more messages");
          _this.disabled = true;
          return _this.render();
        };
        this.collection.fetchOlder(success, error);
        this.clickable = false;
        element = this;
        return setTimeout(function() {
          element.clickable = true;
          return element.render();
        }, 1000 * 7);
      }
    };

    MailsListMore.prototype.render = function() {
      var template;
      this.clickable = true;
      template = require("./templates/_mail/mails_more");
      $(this.el).html(template({
        collection: this.collection,
        disabled: this.disabled
      }));
      return this;
    };

    return MailsListMore;

  })(Backbone.View);
  
});
window.require.register("views/menu", function(exports, require, module) {
  var BaseView, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  BaseView = require('lib/base_view');

  exports.Menu = (function(_super) {
    __extends(Menu, _super);

    function Menu() {
      _ref = Menu.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Menu.prototype.id = 'menu_container';

    Menu.prototype.template = require('templates/menu');

    Menu.prototype.select = function(activeid) {
      this.$(".menu_option").removeClass("active");
      return this.$("#" + activeid).addClass("active");
    };

    return Menu;

  })(BaseView);
  
});
window.require.register("views/message_box", function(exports, require, module) {
  var LogMessage, MessageBoxElement,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  MessageBoxElement = require("views/message_box_element").MessageBoxElement;

  LogMessage = require("models/logmessage").LogMessage;

  /*
          @file: message_box.coffee
          @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
          @description:
              Serves a place to display messages which are meant to be seen by user.
  */


  exports.MessageBox = (function(_super) {
    __extends(MessageBox, _super);

    MessageBox.prototype.id = "message_box";

    function MessageBox(el, collection) {
      this.el = el;
      this.collection = collection;
      this.render = __bind(this.render, this);
      this.renderOne = __bind(this.renderOne, this);
      MessageBox.__super__.constructor.call(this);
    }

    MessageBox.prototype.initialize = function() {
      this.collection.on("add", this.renderOne);
      return this.collection.on("reset", this.render);
    };

    MessageBox.prototype.renderOne = function(logmessage) {
      this.addNewBox(logmessage);
      if (logmessage.get("subtype") === "check" && logmessage.get("type") === "info") {
        logmessage.url = "logs/" + logmessage.id;
        return logmessage.destroy();
      }
    };

    MessageBox.prototype.addNewBox = function(logmessage) {
      var box;
      box = new MessageBoxElement(logmessage, this.collection);
      return this.$el.prepend(box.render().el);
    };

    MessageBox.prototype.render = function() {
      var _this = this;
      this.previousCheckMessage = null;
      this.collection.each(function(message) {
        return _this.renderOne(message);
      });
      return this;
    };

    return MessageBox;

  })(Backbone.View);
  
});
window.require.register("views/message_box_element", function(exports, require, module) {
  /*
      @file: message_box_element.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description:
          Serves a single message to user
  */

  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  exports.MessageBoxElement = (function(_super) {
    __extends(MessageBoxElement, _super);

    function MessageBoxElement(model, collection) {
      this.model = model;
      this.collection = collection;
      this.remove = __bind(this.remove, this);
      this.onCloseClicked = __bind(this.onCloseClicked, this);
      MessageBoxElement.__super__.constructor.call(this);
      this.model.view = this;
    }

    MessageBoxElement.prototype.events = {
      "click button.close": 'onCloseClicked'
    };

    MessageBoxElement.prototype.onCloseClicked = function() {
      if (!(this.model.get("type") === "info" && this.model.get("subtype") === "check")) {
        this.model.url = "logs/" + this.model.id;
        this.model.destroy();
      }
      this.collection.remove(this.model);
      return this.remove();
    };

    MessageBoxElement.prototype.remove = function() {
      this.$el.fadeOut();
      return this.$el.remove();
    };

    MessageBoxElement.prototype.render = function() {
      var template, type;
      if (this.model.get("timeout") !== 0) {
        setTimeout(this.remove, this.model.get("timeout") * 1000);
      }
      type = this.model.get("type");
      if (type === "error") {
        template = require('./templates/_message/message_error');
      } else if (type === "success") {
        template = require('./templates/_message/message_success');
      } else if (type === "warning") {
        template = require('./templates/_message/message_warning');
      } else {
        template = require('./templates/_message/message_info');
      }
      this.$el.html(template({
        model: this.model
      }));
      return this;
    };

    return MessageBoxElement;

  })(Backbone.View);
  
});
window.require.register("views/modal", function(exports, require, module) {
  var BaseView, _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  BaseView = require('lib/base_view');

  exports.Modal = (function(_super) {
    __extends(Modal, _super);

    function Modal() {
      this.showAndThen = __bind(this.showAndThen, this);
      this.events = __bind(this.events, this);
      _ref = Modal.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Modal.prototype.id = 'confirm-delete-modal';

    Modal.prototype.template = require('templates/_mailbox/modal');

    Modal.prototype.className = 'modal hide fade in';

    Modal.prototype.attributes = {
      'role': 'dialog',
      'aria-hidden': 'true'
    };

    Modal.prototype.currentCallback = function() {};

    Modal.prototype.events = function() {
      var _this = this;
      return {
        'click .yes-button': function() {
          return typeof _this.currentCallback === "function" ? _this.currentCallback() : void 0;
        },
        'hide': function() {
          return _this.currentCallback = null;
        }
      };
    };

    Modal.prototype.showAndThen = function(callback) {
      this.currentCallback = callback;
      return this.$el.modal();
    };

    return Modal;

  })(BaseView);
  
});

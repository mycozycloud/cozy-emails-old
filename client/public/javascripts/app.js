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
  (function() {
    var __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    exports.AttachmentsCollection = (function(_super) {

      __extends(AttachmentsCollection, _super);

      function AttachmentsCollection() {
        AttachmentsCollection.__super__.constructor.apply(this, arguments);
      }

      AttachmentsCollection.prototype.comparator = 'filename';

      AttachmentsCollection.prototype.model = require('models/attachment');

      return AttachmentsCollection;

    })(Backbone.Collection);

  }).call(this);
  
});
window.require.register("collections/folders", function(exports, require, module) {
  (function() {
    var __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    exports.FolderCollection = (function(_super) {

      __extends(FolderCollection, _super);

      function FolderCollection() {
        FolderCollection.__super__.constructor.apply(this, arguments);
      }

      FolderCollection.prototype.model = require('models/folder').Folder;

      FolderCollection.prototype.url = 'folders';

      return FolderCollection;

    })(Backbone.Collection);

  }).call(this);
  
});
window.require.register("collections/logmessages", function(exports, require, module) {
  (function() {
    var LogMessage,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

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
        LogMessagesCollection.__super__.constructor.apply(this, arguments);
      }

      LogMessagesCollection.prototype.model = LogMessage;

      LogMessagesCollection.prototype.urlRoot = 'logs/';

      LogMessagesCollection.prototype.comparator = "createdAt";

      return LogMessagesCollection;

    })(Backbone.Collection);

  }).call(this);
  
});
window.require.register("collections/mailboxes", function(exports, require, module) {
  (function() {
    var Mailbox,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

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
        MailboxCollection.__super__.constructor.apply(this, arguments);
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

  }).call(this);
  
});
window.require.register("collections/mails", function(exports, require, module) {
  (function() {
    var Mail,
      __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

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
        this.fetchRainbow = __bind(this.fetchRainbow, this);
        this.fetchFolder = __bind(this.fetchFolder, this);
        this.fetchOlder = __bind(this.fetchOlder, this);
        MailsCollection.__super__.constructor.apply(this, arguments);
      }

      MailsCollection.prototype.model = Mail;

      MailsCollection.prototype.url = 'mails/';

      MailsCollection.prototype.timestampNew = new Date().valueOf();

      MailsCollection.prototype.timestampOld = new Date().valueOf();

      MailsCollection.prototype.timestampMiddle = new Date().valueOf();

      MailsCollection.prototype.mailsAtOnce = 100;

      MailsCollection.prototype.fetchOlder = function() {
        if (this.folderId === 'rainbow') {
          return this.fetchRainbow(this.mailsAtOnce, this.last().get("dateValueOf"));
        } else {
          return this.fetchFolder(this.folderId, this.mailsAtOnce, this.last().get("dateValueOf"));
        }
      };

      MailsCollection.prototype.fetchFolder = function(folderid, limit, from) {
        var _this = this;
        if (!from) this.reset([]);
        this.folderId = folderid;
        return this.fetch({
          url: "folders/" + folderid + "/" + limit + "/" + from,
          remove: false,
          success: function(collection) {
            if (_this.length > 0) {
              _this.timestampNew = _this.at(0).get("dateValueOf");
            }
            if (_this.length > 0) {
              return _this.timestampOld = _this.last().get("dateValueOf");
            }
          }
        });
      };

      MailsCollection.prototype.fetchRainbow = function(limit, from) {
        var _this = this;
        if (!from) this.reset([]);
        this.folderId = 'rainbow';
        return this.fetch({
          url: "mails/rainbow/" + limit + "/" + from,
          remove: false,
          success: function(collection) {
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

  }).call(this);
  
});
window.require.register("helpers", function(exports, require, module) {
  (function() {

    exports.BrunchApplication = (function() {

      function BrunchApplication() {
        var _this = this;
        $(function() {
          return _this.initialize(_this);
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
                  if (color) opts.color = color;
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

  }).call(this);
  
});
window.require.register("initialize", function(exports, require, module) {
  
  /*
      @file: initialize.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description:
          Building object used all over the place - collections, AppView, etc
  */

  (function() {
    var BrunchApplication, FolderCollection, MailboxCollection, MailboxesList, MailsCollection, MailsList, MainRouter, Menu, Modal, SocketListener,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

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
        Application.__super__.constructor.apply(this, arguments);
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
        this.folders = new FolderCollection();
        this.realtimer.watch(this.folders);
        this.mails = new MailsCollection();
        this.realtimer.watch(this.mails);
        this.views.mailList = new MailsList({
          collection: this.mails
        });
        this.views.mailList.$el.appendTo($('body'));
        this.views.mailList.render();
        this.views.modal = new Modal();
        this.views.modal.render().$el.appendTo($('body'));
        return this.mailboxes.fetch({
          error: function() {
            return alert("Error while loading mailboxes");
          },
          success: function() {
            return _this.folders.fetch({
              error: function() {
                return alert("Error while loading folders");
              },
              success: function() {
                return Backbone.history.start();
              }
            });
          }
        });
      };

      return Application;

    })(BrunchApplication);

    window.app = new exports.Application;

  }).call(this);
  
});
window.require.register("lib/base_view", function(exports, require, module) {
  (function() {
    var BaseView,
      __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    module.exports = BaseView = (function(_super) {

      __extends(BaseView, _super);

      function BaseView() {
        this.render = __bind(this.render, this);
        BaseView.__super__.constructor.apply(this, arguments);
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

  }).call(this);
  
});
window.require.register("lib/realtimer", function(exports, require, module) {
  (function() {
    var Folder, Mail, Mailbox, SocketListener,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    Mailbox = require('models/mailbox').Mailbox;

    Mail = require('models/mail').Mail;

    Folder = require('models/folder').Folder;

    module.exports = SocketListener = (function(_super) {

      __extends(SocketListener, _super);

      function SocketListener() {
        SocketListener.__super__.constructor.apply(this, arguments);
      }

      SocketListener.prototype.models = {
        'mailbox': Mailbox,
        'folder': Folder,
        'mail': Mail
      };

      SocketListener.prototype.events = ['mailbox.create', 'mailbox.update', 'mailbox.delete', 'folder.create', 'folder.update', 'folder.delete', 'mail.create', 'mail.update', 'mail.delete'];

      SocketListener.prototype.onRemoteCreate = function(model) {
        if (model instanceof Mailbox) {
          app.mailboxes.add(model);
        } else if (model instanceof Folder) {
          app.folders.add(model);
        }
        if (model instanceof Mail && app.mails.folderId === model.folder) {
          return app.mails.add(model);
        }
      };

      SocketListener.prototype.onRemoteDelete = function(model) {
        return model.trigger('destroy', model, model.collection, {});
      };

      return SocketListener;

    })(CozySocketListener);

  }).call(this);
  
});
window.require.register("lib/view_collection", function(exports, require, module) {
  (function() {
    var BaseView, ViewCollection,
      __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    BaseView = require('lib/base_view');

    module.exports = ViewCollection = (function(_super) {

      __extends(ViewCollection, _super);

      function ViewCollection() {
        this.removeItem = __bind(this.removeItem, this);
        this.addItem = __bind(this.addItem, this);
        ViewCollection.__super__.constructor.apply(this, arguments);
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
        var id, view, _ref;
        _ref = this.views;
        for (id in _ref) {
          view = _ref[id];
          view.$el.detach();
        }
        return ViewCollection.__super__.render.apply(this, arguments);
      };

      ViewCollection.prototype.afterRender = function() {
        var id, view, _ref;
        _ref = this.views;
        for (id in _ref) {
          view = _ref[id];
          this.appendView(view);
        }
        return this.checkIfEmpty(this.views);
      };

      ViewCollection.prototype.remove = function() {
        this.onReset([]);
        return ViewCollection.__super__.remove.apply(this, arguments);
      };

      ViewCollection.prototype.onReset = function(newcollection) {
        var id, view, _ref;
        _ref = this.views;
        for (id in _ref) {
          view = _ref[id];
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

  }).call(this);
  
});
window.require.register("models/attachment", function(exports, require, module) {
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
  
});
window.require.register("models/folder", function(exports, require, module) {
  (function() {
    var BaseModel,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    BaseModel = require("./models").BaseModel;

    exports.Folder = (function(_super) {

      __extends(Folder, _super);

      function Folder() {
        Folder.__super__.constructor.apply(this, arguments);
      }

      Folder.prototype.urlRoot = 'folders/';

      return Folder;

    })(BaseModel);

  }).call(this);
  
});
window.require.register("models/logmessage", function(exports, require, module) {
  (function() {
    var BaseModel,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

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
        LogMessage.__super__.constructor.apply(this, arguments);
      }

      LogMessage.prototype.urlRoot = "logs/";

      LogMessage.prototype.idAttribute = "id";

      return LogMessage;

    })(BaseModel);

  }).call(this);
  
});
window.require.register("models/mail", function(exports, require, module) {
  (function() {
    var BaseModel,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

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
        var _ref;
        return ((_ref = this.getMailbox()) != null ? _ref.get("color") : void 0) || "white";
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
        if (read == null) read = true;
        if (read) {
          return this.set('flags', _.union(this.get('flags'), ["\\Seen"]));
        } else {
          return this.set('flags', _.without(this.get('flags'), "\\Seen"));
        }
      };

      Mail.prototype.markFlagged = function(flagged) {
        if (flagged == null) flagged = true;
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
        if (this.get("from")) this.asEmailList("from", out);
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
        if (this.get("cc")) out = this.asEmailList("cc", out);
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
        if (this.get("from")) this.asEmailList("from", out);
        if (this.get("cc")) this.asEmailList("cc", out);
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

  }).call(this);
  
});
window.require.register("models/mail_sent", function(exports, require, module) {
  (function() {
    var BaseModel,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

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
        MailSent.__super__.constructor.apply(this, arguments);
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
        if (this.view != null) return this.view.render();
      };

      MailSent.prototype.removeView = function() {
        if (this.view != null) return this.view.remove();
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

  }).call(this);
  
});
window.require.register("models/mailbox", function(exports, require, module) {
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
            MAILBOX stocks all the data necessary for a successful connection to
            IMAP and SMTP servers, and all the data relative to this mailbox,
            internal to the application.
    */

    exports.Mailbox = (function(_super) {

      __extends(Mailbox, _super);

      function Mailbox() {
        Mailbox.__super__.constructor.apply(this, arguments);
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

      Mailbox.prototype.destroy = function(options) {
        var id, success;
        success = options.success;
        id = this.id;
        options.success = function() {
          app.folders.forEach(function(folder) {
            console.log(folder, id);
            if (folder.get('mailbox') === id) return app.folders.remove(folder);
          });
          app.mails.forEach(function(mail) {
            console.log(mail, id);
            if (mail.mailbox === id) return app.mails.remove(mail);
          });
          if (success) return success.apply(this, arguments);
        };
        return Mailbox.__super__.destroy.call(this, options);
      };

      return Mailbox;

    })(BaseModel);

  }).call(this);
  
});
window.require.register("models/models", function(exports, require, module) {
  (function() {
    var __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    exports.BaseModel = (function(_super) {

      __extends(BaseModel, _super);

      function BaseModel() {
        BaseModel.__super__.constructor.apply(this, arguments);
      }

      return BaseModel;

    })(Backbone.Model);

  }).call(this);
  
});
window.require.register("routers/main_router", function(exports, require, module) {
  (function() {
    var Mail, MailView, Mailbox, MailboxForm,
      __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

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
        this.foldermail = __bind(this.foldermail, this);
        this.rainbowmail = __bind(this.rainbowmail, this);
        this.rainbow = __bind(this.rainbow, this);
        MainRouter.__super__.constructor.apply(this, arguments);
      }

      MainRouter.prototype.routes = {
        '': 'rainbow',
        'rainbow': 'rainbow',
        'rainbow/mail/:id': 'rainbowmail',
        'folder/:id': 'folder',
        'folder/:id/mail/:mid': 'foldermail',
        'config': 'config',
        'config/mailboxes': 'config',
        'config/mailboxes/new': 'newMailbox',
        'config/mailboxes/:id': 'editMailbox'
      };

      MainRouter.prototype.clear = function() {
        var _ref, _ref2;
        app.views.mailboxList.activate(null);
        app.views.mailList.activate(null);
        app.views.mailList.$el.hide();
        app.views.mailboxList.$el.hide();
        if ((_ref = app.views.mail) != null) _ref.remove();
        if ((_ref2 = app.views.mailboxform) != null) _ref2.remove();
        app.views.mail = null;
        return app.views.mailboxform = null;
      };

      MainRouter.prototype.rainbow = function(callback) {
        this.clear();
        app.views.menu.select('inboxbutton');
        app.views.mailboxList.$el.hide();
        app.views.mailList.$el.show();
        app.views.mailList.$el.getNiceScroll().show();
        return app.mails.fetchRainbow(100).then(callback);
      };

      MainRouter.prototype.rainbowmail = function(mailid) {
        var _this = this;
        if (app.mails.folderId === 'rainbow') {
          return this.mail(mailid);
        } else {
          return this.rainbow(function() {
            return _this.mail(mailid, 'rainbow');
          });
        }
      };

      MainRouter.prototype.folder = function(folderid, callback) {
        this.clear();
        app.views.menu.select('inboxbutton');
        app.views.mailboxList.$el.hide();
        app.views.mailList.$el.show();
        app.views.mailList.$el.getNiceScroll().show();
        return app.mails.fetchFolder(folderid, 100).then(callback);
      };

      MainRouter.prototype.foldermail = function(folderid, mailid) {
        var _this = this;
        if (app.mails.folderId === folderid) {
          return this.mail(mailid);
        } else {
          return this.folder(folderid, function() {
            return _this.mail(mailid, "folder/" + folderid);
          });
        }
      };

      MainRouter.prototype.mail = function(id, list) {
        var model, _ref;
        if (model = app.mails.get(id)) {
          if ((_ref = app.views.mail) != null) _ref.remove();
          app.views.mail = new MailView({
            model: model
          });
          app.views.mail.$el.appendTo($('body'));
          return app.views.mail.render();
        } else {
          return this.navigate(list, true);
        }
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

      return MainRouter;

    })(Backbone.Router);

  }).call(this);
  
});
window.require.register("templates/_attachment/attachment_element", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<i');
  buf.push(attrs({ "class": ('icon-file') }));
  buf.push('></i><a');
  buf.push(attrs({ 'href':("" + (href) + ""), 'target':("_blank") }));
  buf.push('>' + escape((interp = attachment.get("fileName")) == null ? '' : interp) + '</a>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_layouts/layout_compose_mail", function(exports, require, module) {
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
});
window.require.register("templates/_layouts/layout_mailboxes", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div><div');
  buf.push(attrs({ 'id':('mailboxes') }));
  buf.push('></div><div');
  buf.push(attrs({ 'id':('add_mail_button_container') }));
  buf.push('></div></div>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_layouts/layout_mails", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div');
  buf.push(attrs({ "class": ('row-fluid') }));
  buf.push('><div');
  buf.push(attrs({ 'id':('column_mails_list'), "class": ('column') + ' ' + ('span5') }));
  buf.push('></div><div');
  buf.push(attrs({ 'id':('column_mail'), "class": ('column') }));
  buf.push('></div></div>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_mail/attachments", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<h3');
  buf.push(attrs({ "class": ('attachments-title') }));
  buf.push('>attachments</h3><div');
  buf.push(attrs({ 'id':('attachments_list') }));
  buf.push('></div>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_mail/big", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div');
  buf.push(attrs({ 'id':('additional_bar'), "class": ('btn-toolbar') }));
  buf.push('><a');
  buf.push(attrs({ 'id':('btn-flagged'), "class": ('btn') + ' ' + ('btn-warning') }));
  buf.push('>');
  if ( model.isFlagged())
  {
  buf.push('<i');
  buf.push(attrs({ "class": ('icon-star-empty') + ' ' + ('icon-white') }));
  buf.push('></i>Unflag\n');
  }
  else
  {
  buf.push('<i');
  buf.push(attrs({ "class": ('icon-star') + ' ' + ('icon-white') }));
  buf.push('></i>Flag\n');
  }
  buf.push('</a><a');
  buf.push(attrs({ 'id':('btn-unread'), "class": ('btn') }));
  buf.push('>');
  if ( model.isRead())
  {
  buf.push('<i');
  buf.push(attrs({ "class": ('icon-eye-close') + ' ' + ('icon-white') }));
  buf.push('></i>Keep unread\n');
  }
  else
  {
  buf.push('<i');
  buf.push(attrs({ "class": ('icon-eye-open') + ' ' + ('icon-white') }));
  buf.push('></i>Mark read\n');
  }
  buf.push('</a><a');
  buf.push(attrs({ 'id':('btn-delete'), "class": ('btn') + ' ' + ('btn-danger') }));
  buf.push('><i');
  buf.push(attrs({ "class": ('icon-remove') + ' ' + ('icon-white') }));
  buf.push('></i>Delete\n</a></div><div');
  buf.push(attrs({ "class": ('well') + ' ' + ('mail-panel') }));
  buf.push('><p>' + escape((interp = model.fromShort()) == null ? '' : interp) + '\n<i');
  buf.push(attrs({ "class": ('date') }));
  buf.push('>' + escape((interp = model.date()) == null ? '' : interp) + '</i>');
  if ( model.get("cc"))
  {
  buf.push('<p>CC:  ' + escape((interp = model.cc()) == null ? '' : interp) + '\n</p>');
  }
  buf.push('</p><h3>' + escape((interp = model.get("subject")) == null ? '' : interp) + '</h3><br');
  buf.push(attrs({  }));
  buf.push('/>');
  if ( model.hasHtml())
  {
  buf.push('<iframe');
  buf.push(attrs({ 'id':('mail_content_html'), 'name':("mail_content_html") }));
  buf.push('>' + ((interp = model.html()) == null ? '' : interp) + '\n</iframe>');
  }
  else
  {
  buf.push('<div');
  buf.push(attrs({ 'id':('mail_content_text') }));
  buf.push('>' + ((interp = model.text()) == null ? '' : interp) + '\n</div>');
  }
  buf.push('</div><div');
  buf.push(attrs({ 'id':('answer_form') }));
  buf.push('></div>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_mail/list", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div');
  buf.push(attrs({ 'id':('topbar') }));
  buf.push('><a');
  buf.push(attrs({ 'id':('refresh-btn'), "class": ('btn') + ' ' + ('btn-primary') }));
  buf.push('>Refresh</a><a');
  buf.push(attrs({ 'id':('markallread-btn'), "class": ('btn') + ' ' + ('btn-primary') }));
  buf.push('>Mark all as read</a></div><div');
  buf.push(attrs({ 'id':('no-mails-message'), "class": ('well') }));
  buf.push('><h3>Hey !</h3><p>It looks like there are no mails to show.</p><p>May be you need to configure your mailboxes :<a');
  buf.push(attrs({ 'href':("#config/mailboxes") }));
  buf.push('>Click Here</a></p><p>If You just did it, and still see no messages, you may need to wait for\nus to download them for you. Enjoy  :)\n\n</p></div><table');
  buf.push(attrs({ "class": ('table') + ' ' + ('table-striped') }));
  buf.push('><tbody');
  buf.push(attrs({ 'id':('mails_list_container') }));
  buf.push('></tbody></table><div');
  buf.push(attrs({ 'id':('more-button') }));
  buf.push('><a');
  buf.push(attrs({ 'id':('add_more_mails'), "class": ('btn') + ' ' + ('btn-primary') + ' ' + ('btn-large') }));
  buf.push('>more messages</a></div>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_mail/mail_answer", function(exports, require, module) {
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
  buf.push('>underline</a><a');
  buf.push(attrs({ 'data-wysihtml5-command':('insertUnorderedList'), "class": ('btn') + ' ' + ('btn-mini') }));
  buf.push('>list</a></div><div');
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
  buf.push('><br');
  buf.push(attrs({  }));
  buf.push('/><br');
  buf.push(attrs({  }));
  buf.push('/><p>' + escape((interp = model.respondingToText()) == null ? '' : interp) + '\n</p><blockquote');
  buf.push(attrs({ 'style':("border-left: 3px lightgray solid; margin-left: 15px; padding-left: 5px; color: lightgray; font-style:italic;") }));
  buf.push('>' + ((interp = model.htmlOrText()) == null ? '' : interp) + '\n</blockquote></textarea><a');
  buf.push(attrs({ 'id':('send_button'), "class": ('btn') + ' ' + ('btn-primary') + ' ' + ('btn-large') }));
  buf.push('>Send !</a></div></div></fieldset></form>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_mail/mail_compose", function(exports, require, module) {
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
  buf.push('>underline</a><a');
  buf.push(attrs({ 'data-wysihtml5-command':('insertUnorderedList'), "class": ('btn') + ' ' + ('btn-mini') }));
  buf.push('>list</a></div><div');
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
});
window.require.register("templates/_mail/mail_list", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<td');
  buf.push(attrs({ 'title':(mailboxName), 'style':('width: 5px; padding: 0; background-color: ' + model.getColor() + ';') }));
  buf.push('></td><td');
  buf.push(attrs({ 'title':(model.isFlagged()?'Unstar':'Star'), "class": ('toggleflag') }));
  buf.push('>');
  if ( model.isFlagged())
  {
  buf.push('<i');
  buf.push(attrs({ "class": ('icon-star') }));
  buf.push('></i>');
  }
  else
  {
  buf.push('<i');
  buf.push(attrs({ "class": ('icon-star-empty') }));
  buf.push('></i>');
  }
  buf.push('</td><td');
  buf.push(attrs({ 'title':(mailboxName), "class": (model.isRead()?'read':'unread') }));
  buf.push('><h4>' + escape((interp = model.fromShort()) == null ? '' : interp) + '<i');
  buf.push(attrs({ "class": ('date') }));
  buf.push('>' + escape((interp = model.date()) == null ? '' : interp) + '</i>');
  if ( model.hasAttachments())
  {
  buf.push('<i');
  buf.push(attrs({ "class": ('icon-file') }));
  buf.push('></i>');
  }
  buf.push('</h4><p');
  buf.push(attrs({ "class": ('subject') }));
  buf.push('>' + escape((interp = model.get("subject")) == null ? '' : interp) + '\n</p></td>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_mail/mail_new", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div');
  buf.push(attrs({ 'style':("margin-bottom: 10px; margin-top: 0px;"), "class": ('btn-group') + ' ' + ('center') }));
  buf.push('><a');
  buf.push(attrs({ 'id':('get_new_mails'), "class": ('btn') + ' ' + ('btn-primary') + ' ' + ('btn-large') }));
  buf.push('> Check for new mail\n</a></div>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_mail/mail_sent", function(exports, require, module) {
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
});
window.require.register("templates/_mailbox/form", function(exports, require, module) {
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
  buf.push(attrs({ 'for':("login"), "class": ('control-label') }));
  buf.push('>Your login</label><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><input');
  buf.push(attrs({ 'id':("login"), 'type':("text"), 'value':(model.get("login")), "class": ('content') + ' ' + ('input-xlarge') }));
  buf.push('/></div></div><div');
  buf.push(attrs({ "class": ('control-group') }));
  buf.push('><label');
  buf.push(attrs({ 'for':("password"), "class": ('control-label') }));
  buf.push('>Your password</label><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><input');
  buf.push(attrs({ 'id':("password"), 'type':("password"), 'value':(model.get("password")), "class": ('content') + ' ' + ('input-xlarge') }));
  buf.push('/><p');
  buf.push(attrs({ "class": ('help-block') }));
  buf.push('>Login and password you use for this mailbox. It\'s stored safely, don\'t worry.</p></div></div><div');
  buf.push(attrs({ "class": ('control-group') }));
  buf.push('><label');
  buf.push(attrs({ 'for':("color"), "class": ('control-label') }));
  buf.push('>Rainbows and unicorns</label><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><select');
  buf.push(attrs({ 'id':("color"), 'selected':(model.get("color")), "class": ('content') + ' ' + ('input-xlarge') }));
  buf.push('><option');
  buf.push(attrs({ 'value':("orange"), 'selected':("orange" === model.get("color")) }));
  buf.push('>orange</option><option');
  buf.push(attrs({ 'value':("blue"), 'selected':("blue" === model.get("color")) }));
  buf.push('>blue</option><option');
  buf.push(attrs({ 'value':("red"), 'selected':("red" === model.get("color")) }));
  buf.push('>red</option><option');
  buf.push(attrs({ 'value':("green"), 'selected':("green" === model.get("color")) }));
  buf.push('>green</option><option');
  buf.push(attrs({ 'value':("gold"), 'selected':("gold" === model.get("color")) }));
  buf.push('>gold</option><option');
  buf.push(attrs({ 'value':("purple"), 'selected':("purple" === model.get("color")) }));
  buf.push('>purple</option><option');
  buf.push(attrs({ 'value':("pink"), 'selected':("pink" === model.get("color")) }));
  buf.push('>pink</option><option');
  buf.push(attrs({ 'value':("black"), 'selected':("black" === model.get("color")) }));
  buf.push('>black</option><option');
  buf.push(attrs({ 'value':("brown"), 'selected':("brown" === model.get("color")) }));
  buf.push('>brown</option></select><p');
  buf.push(attrs({ "class": ('help-block') }));
  buf.push('>The color to mark mails from this inbox. Enjoy!</p></div></div></fieldset><fieldset><legend>Server data</legend><div');
  buf.push(attrs({ "class": ('control-group') }));
  buf.push('><label');
  buf.push(attrs({ 'for':("imapServer"), "class": ('control-label') }));
  buf.push('>IMAP host</label><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><input');
  buf.push(attrs({ 'id':("imapServer"), 'type':("text"), 'value':(model.get("imapServer")), "class": ('content') + ' ' + ('input-xlarge') }));
  buf.push('/><p');
  buf.push(attrs({ "class": ('help-block') }));
  buf.push('>The inbound server address. Say imap.gmail.com ..</p></div></div><div');
  buf.push(attrs({ "class": ('control-group') }));
  buf.push('><label');
  buf.push(attrs({ 'for':("imapPort"), "class": ('control-label') }));
  buf.push('>IMAP port</label><div');
  buf.push(attrs({ "class": ('controls') }));
  buf.push('><input');
  buf.push(attrs({ 'id':("imapPort"), 'type':("text"), 'value':(model.get("imapPort")), "class": ('content') + ' ' + ('input-xlarge') }));
  buf.push('/><p');
  buf.push(attrs({ "class": ('help-block') }));
  buf.push('>Usually 993.</p></div></div></fieldset><div');
  buf.push(attrs({ "class": ('form-actions') }));
  buf.push('><button');
  buf.push(attrs({ "class": ('save_mailbox') + ' ' + ('isEdit') + ' ' + ('btn') + ' ' + ('btn-success') }));
  buf.push('>save</button><button');
  buf.push(attrs({ "class": ('cancel_edit_mailbox') + ' ' + ('isEdit') + ' ' + ('btn') + ' ' + ('btn-warning') }));
  buf.push('>cancel</button></div></from>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_mailbox/list", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<p');
  buf.push(attrs({ 'id':('no-mailbox-msg') }));
  buf.push('>no mailbox found</p><div');
  buf.push(attrs({ 'id':('add_mailbox_button_container') }));
  buf.push('><a');
  buf.push(attrs({ 'href':("#config/mailboxes/new"), 'id':('add_mailbox'), "class": ('btn') }));
  buf.push('>Add a new mailbox</a></div>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_mailbox/modal", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div');
  buf.push(attrs({ "class": ('modal-header') }));
  buf.push('><h3');
  buf.push(attrs({ 'id':('confirm-delete-modal-label') }));
  buf.push('>Warning!</h3></div><div');
  buf.push(attrs({ "class": ('modal-body') }));
  buf.push('><p>You are about to delete a mailbox and all its mails. Do you\nyou want to continue?\n</p></div><div');
  buf.push(attrs({ "class": ('modal-footer') }));
  buf.push('><button');
  buf.push(attrs({ 'data-dismiss':("modal"), 'aria-hidden':("true"), "class": ('yes-button') + ' ' + ('btn') }));
  buf.push('>Yes</button><button');
  buf.push(attrs({ 'data-dismiss':("modal"), 'aria-hidden':("true"), "class": ('no-button') + ' ' + ('btn') + ' ' + ('btn-info') }));
  buf.push('>No</button></div>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_mailbox/thumb", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<span');
  buf.push(attrs({ 'style':("background-color: " + (model.get('color')) + ";"), "class": ('badge') }));
  buf.push('></span><h3>' + escape((interp = model.get('name')) == null ? '' : interp) + '</h3>');
  if ( model.get("statusMsg"))
  {
  buf.push('<span');
  buf.push(attrs({ "class": ('mailbox-status') }));
  buf.push('>' + escape((interp = model.get('statusMsg')) == null ? '' : interp) + '</span>');
  }
  buf.push('<button');
  buf.push(attrs({ "class": ('edit-mailbox') + ' ' + ('btn') }));
  buf.push('>edit</button><button');
  buf.push(attrs({ "class": ('delete-mailbox') + ' ' + ('btn') + ' ' + ('btn-danger') }));
  buf.push('>delete</button>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_mailsent/mailsent_big", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div');
  buf.push(attrs({ "class": ('well') }));
  buf.push('><p>To: ' + escape((interp = model.to()) == null ? '' : interp) + '\n');
  if ( model.hasCC())
  {
  buf.push('<p>Cc:  ' + escape((interp = model.cc()) == null ? '' : interp) + '\n</p>');
  }
  if ( model.hasBCC())
  {
  buf.push('<p>Bcc:  ' + escape((interp = model.bcc()) == null ? '' : interp) + '\n</p>');
  }
  buf.push('</p><p><i');
  buf.push(attrs({ 'style':('color: lightgray;') }));
  buf.push('>sent ' + escape((interp = model.date()) == null ? '' : interp) + '</i><br');
  buf.push(attrs({  }));
  buf.push('/></p><h3>' + escape((interp = model.get("subject")) == null ? '' : interp) + '</h3><br');
  buf.push(attrs({  }));
  buf.push('/><iframe');
  buf.push(attrs({ 'id':('mail_content_html'), 'id':("mail_content_html"), 'name':("mail_content_html") }));
  buf.push('>' + ((interp = model.html()) == null ? '' : interp) + '\n</iframe></div>');
  if ( model.hasAttachments())
  {
  buf.push('<div');
  buf.push(attrs({ 'id':('attachments_list'), "class": ('well') }));
  buf.push('></div>');
  }
  }
  return buf.join("");
  };
});
window.require.register("templates/_mailsent/mailsent_list", function(exports, require, module) {
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
  buf.push('><p><strong>' + escape((interp = model.toShort()) == null ? '' : interp) + '</strong>');
  if ( model.hasAttachments())
  {
  buf.push('<i');
  buf.push(attrs({ "class": ('icon-file') }));
  buf.push('></i>');
  }
  buf.push('<br');
  buf.push(attrs({  }));
  buf.push('/><i');
  buf.push(attrs({ 'style':('color: black;') }));
  buf.push('>' + escape((interp = model.date()) == null ? '' : interp) + '</i><p>' + escape((interp = model.get("subject")) == null ? '' : interp) + '</p></p></td>');
  }
  else
  {
  buf.push('<td><p><strong>' + escape((interp = model.toShort()) == null ? '' : interp) + '</strong>');
  if ( model.hasAttachments())
  {
  buf.push('<i');
  buf.push(attrs({ "class": ('icon-file') }));
  buf.push('></i>');
  }
  buf.push('<br');
  buf.push(attrs({  }));
  buf.push('/><i');
  buf.push(attrs({ 'style':('color: gray;') }));
  buf.push('>' + escape((interp = model.date()) == null ? '' : interp) + '</i><p>' + escape((interp = model.get("subject")) == null ? '' : interp) + '</p></p></td>');
  }
  }
  }
  return buf.join("");
  };
});
window.require.register("templates/_message/message_error", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div');
  buf.push(attrs({ "class": ('alert') + ' ' + ('alert-error') }));
  buf.push('><button');
  buf.push(attrs({ 'type':("button"), 'data-dismiss':("alert"), "class": ('close') }));
  buf.push('>x</button><strong>Oh, snap !\n</strong><p>' + ((interp = model.get("text")) == null ? '' : interp) + '\n</p></div>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_message/message_info", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div');
  buf.push(attrs({ "class": ('alert') + ' ' + ('alert-info') }));
  buf.push('><button');
  buf.push(attrs({ 'type':("button"), 'data-dismiss':("alert"), "class": ('close') }));
  buf.push('>x</button><strong>Heads up!\n</strong><p>' + ((interp = model.get("text")) == null ? '' : interp) + '\n</p></div>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_message/message_success", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div');
  buf.push(attrs({ "class": ('alert') + ' ' + ('alert-success') }));
  buf.push('><button');
  buf.push(attrs({ 'type':("button"), 'data-dismiss':("alert"), "class": ('close') }));
  buf.push('>x</button><strong>Well done !\n</strong><p>' + ((interp = model.get("text")) == null ? '' : interp) + '\n</p></div>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_message/message_warning", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<div');
  buf.push(attrs({ "class": ('alert') }));
  buf.push('><button');
  buf.push(attrs({ 'type':("button"), 'data-dismiss':("alert"), "class": ('close') }));
  buf.push('>x</button><strong>Warning !\n</strong><p>' + ((interp = model.get("text")) == null ? '' : interp) + '\n</p></div>');
  }
  return buf.join("");
  };
});
window.require.register("templates/_message/normal", function(exports, require, module) {
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
});
window.require.register("templates/app", function(exports, require, module) {
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
  buf.push(attrs({ 'id':('sidebar'), "class": ('span1') }));
  buf.push('><div');
  buf.push(attrs({ 'id':('menu_container'), "class": ('well') + ' ' + ('sidebar-nav') }));
  buf.push('></div></div><div');
  buf.push(attrs({ 'id':('content') }));
  buf.push('></div><div');
  buf.push(attrs({ 'id':('box-content') }));
  buf.push('></div></div></div>');
  }
  return buf.join("");
  };
});
window.require.register("templates/folders_menu", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<a');
  buf.push(attrs({ 'data-toggle':("dropdown"), 'href':("#"), "class": ('btn') + ' ' + ('dropdown-toggle') }));
  buf.push('><span');
  buf.push(attrs({ 'id':('currentfolder') }));
  buf.push('>Choose Folder</span><span');
  buf.push(attrs({ "class": ('caret') }));
  buf.push('></span></a><ul');
  buf.push(attrs({ 'id':('folderlist'), "class": ('dropdown-menu') + ' ' + ('pull-right') + ' ' + ('nav') }));
  buf.push('><li><a');
  buf.push(attrs({ 'href':("#rainbow") }));
  buf.push('>The Rainbow</a></li></ul>');
  }
  return buf.join("");
  };
});
window.require.register("templates/menu", function(exports, require, module) {
  module.exports = function anonymous(locals, attrs, escape, rethrow) {
  var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
  var buf = [];
  with (locals || {}) {
  var interp;
  buf.push('<ul');
  buf.push(attrs({ "class": ('nav') + ' ' + ('nav-list') }));
  buf.push('><li');
  buf.push(attrs({ 'id':('inboxbutton'), "class": ('menu_option') }));
  buf.push('><a');
  buf.push(attrs({ 'href':('#rainbow') }));
  buf.push('><img');
  buf.push(attrs({ 'src':("img/icon-mails.png") }));
  buf.push('/></a></li><li');
  buf.push(attrs({ 'id':('mailboxesbutton'), "class": ('menu_option') }));
  buf.push('><a');
  buf.push(attrs({ 'href':('#config/mailboxes') }));
  buf.push('><img');
  buf.push(attrs({ 'src':("img/icon-config.png") }));
  buf.push('/></a></li></ul>');
  }
  return buf.join("");
  };
});
window.require.register("views/_old/mails_answer", function(exports, require, module) {
  (function() {
    var Mail, MailNew,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

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
  
});
window.require.register("views/_old/mails_column", function(exports, require, module) {
  (function() {
    var Mail, MailsList, MailsListMore, MailsListNew,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

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

  }).call(this);
  
});
window.require.register("views/_old/mails_compose", function(exports, require, module) {
  (function() {
    var Mail, MailNew, MailsAnswer,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

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
        var editor, template;
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
        } catch (error) {
          return console.log(error.toString());
        }
      };

      return MailsCompose;

    })(Backbone.View);

  }).call(this);
  
});
window.require.register("views/_old/mails_list_more", function(exports, require, module) {
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
            if (nbMails === 0) return $(_this.el).hide();
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

  }).call(this);
  
});
window.require.register("views/_old/mails_list_new", function(exports, require, module) {
  (function() {
    var Mail,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

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
            if (err) alert("An error occured while fetching mails.");
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

  }).call(this);
  
});
window.require.register("views/_old/mailssent_column", function(exports, require, module) {
  (function() {
    var MailsSentList, MailsSentListMore,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

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

  }).call(this);
  
});
window.require.register("views/_old/mailssent_element", function(exports, require, module) {
  (function() {
    var MailSent, MailsAttachmentsList,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

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

  }).call(this);
  
});
window.require.register("views/_old/mailssent_list", function(exports, require, module) {
  (function() {
    var MailsSentListElement,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

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

  }).call(this);
  
});
window.require.register("views/_old/mailssent_list_element", function(exports, require, module) {
  (function() {
    var MailSent,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
      __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

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

  }).call(this);
  
});
window.require.register("views/_old/mailssent_list_more", function(exports, require, module) {
  (function() {
    var MailSent,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

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

  }).call(this);
  
});
window.require.register("views/_old/menu_mailboxes_list", function(exports, require, module) {
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

  }).call(this);
  
});
window.require.register("views/_old/menu_mailboxes_list_element", function(exports, require, module) {
  
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

  }).call(this);
  
});
window.require.register("views/app", function(exports, require, module) {
  (function() {
    var MailboxCollection, MailboxesList, MailsCollection, MailsList, Menu,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

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
        AppView.__super__.constructor.apply(this, arguments);
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

  }).call(this);
  
});
window.require.register("views/folders_menu", function(exports, require, module) {
  (function() {
    var FolderMenu, ViewCollection,
      __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

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
        this.appendView = __bind(this.appendView, this);
        this.initialize = __bind(this.initialize, this);
        FolderMenu.__super__.constructor.apply(this, arguments);
      }

      FolderMenu.prototype.id = "folders-menu";

      FolderMenu.prototype.tagName = "div";

      FolderMenu.prototype.className = "btn-group";

      FolderMenu.prototype.itemView = require('views/folders_menu_element');

      FolderMenu.prototype.template = require('templates/folders_menu');

      FolderMenu.prototype.initialize = function() {
        FolderMenu.__super__.initialize.apply(this, arguments);
        return this.currentMailbox = '';
      };

      FolderMenu.prototype.checkIfEmpty = function() {
        return this.$el.toggle(_.size(this.views) !== 0);
      };

      FolderMenu.prototype.appendView = function(view) {
        var title;
        if (this.currentMailbox !== view.model.get('mailbox')) {
          this.currentMailbox = view.model.get('mailbox');
          title = app.mailboxes.get(this.currentMailbox).get('name');
          this.$('#folderlist').append("<li class='nav-header'>" + title + "</li>");
        }
        return this.$('#folderlist').append(view.$el);
      };

      return FolderMenu;

    })(ViewCollection);

  }).call(this);
  
});
window.require.register("views/folders_menu_element", function(exports, require, module) {
  (function() {
    var BaseView, FolderMenuElement,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    BaseView = require('lib/base_view');

    module.exports = FolderMenuElement = (function(_super) {

      __extends(FolderMenuElement, _super);

      function FolderMenuElement() {
        FolderMenuElement.__super__.constructor.apply(this, arguments);
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

  }).call(this);
  
});
window.require.register("views/mail", function(exports, require, module) {
  (function() {
    var BaseView, Mail, MailAttachmentsList,
      __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

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
        MailView.__super__.constructor.apply(this, arguments);
      }

      MailView.prototype.id = 'mail';

      MailView.prototype.events = {
        "click #btn-unread": 'buttonUnread',
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
        this.listenTo(this.model, 'change', this.render);
        return this.attachmentsView = new MailAttachmentsList({
          model: this.model
        });
      };

      MailView.prototype.afterRender = function() {
        var _ref,
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
            if (_this.iframehtml.height() > 600) return $("#additional_bar").hide();
          }, 50);
          this.timeout2 = setTimeout(function() {
            _this.timeout2 = null;
            _this.iframe = _this.$("#mail_content_html");
            return _this.iframe.height(_this.iframehtml.height());
          }, 1000);
        }
        if (this.model.get("hasAttachments")) {
          if ((_ref = this.attachmentsView) != null) {
            _ref.render().$el.appendTo(this.$el);
          }
        }
        return this.$el.niceScroll();
      };

      MailView.prototype.remove = function() {
        this.$el.getNiceScroll().remove();
        MailView.__super__.remove.apply(this, arguments);
        if (this.timeout1) clearTimeout(this.timeout1);
        if (this.timeout2) return clearTimeout(this.timeout2);
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
        console.log("UNREAD");
        this.model.markRead(!this.model.isRead());
        return this.model.save(null, {
          ignoreMySocketNotification: true
        });
      };

      MailView.prototype.buttonFlagged = function() {
        this.model.markFlagged(!this.model.isFlagged());
        return this.model.save(null, {
          ignoreMySocketNotification: true
        });
      };

      MailView.prototype.buttonDelete = function() {
        var base;
        base = app.mails.folderId === 'rainbow' ? 'rainbow' : "folder/" + app.mails.folderId;
        app.router.navigate(base, true);
        return this.model.destroy();
      };

      return MailView;

    })(BaseView);

  }).call(this);
  
});
window.require.register("views/mail_attachments_list", function(exports, require, module) {
  (function() {
    var MailAttachmentsListElement, ViewCollection,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

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

  }).call(this);
  
});
window.require.register("views/mail_attachments_list_element", function(exports, require, module) {
  
  /*
      @file: mails_attachments_list_element.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description:
          Renders clickable attachments link.
  */

  (function() {
    var BaseView,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    BaseView = require('lib/base_view');

    exports.MailAttachmentsListElement = (function(_super) {

      __extends(MailAttachmentsListElement, _super);

      function MailAttachmentsListElement() {
        MailAttachmentsListElement.__super__.constructor.apply(this, arguments);
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

  }).call(this);
  
});
window.require.register("views/mailboxes_list", function(exports, require, module) {
  (function() {
    var Mailbox, ViewCollection,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

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
        MailboxesList.__super__.constructor.apply(this, arguments);
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
        var cid, view, _ref, _results;
        _ref = this.views;
        _results = [];
        for (cid in _ref) {
          view = _ref[cid];
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

  }).call(this);
  
});
window.require.register("views/mailboxes_list_element", function(exports, require, module) {
  
  /*
      @file: mailboxes_list_element.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description:
          The element of the list of mailboxes.
          mailboxes_list -> mailboxes_list_element
  */

  (function() {
    var BaseView, MailboxesListElement,
      __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    BaseView = require('lib/base_view');

    module.exports = MailboxesListElement = (function(_super) {

      __extends(MailboxesListElement, _super);

      function MailboxesListElement() {
        this.buttonDelete = __bind(this.buttonDelete, this);
        this.buttonEdit = __bind(this.buttonEdit, this);
        MailboxesListElement.__super__.constructor.apply(this, arguments);
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

  }).call(this);
  
});
window.require.register("views/mailboxes_list_form", function(exports, require, module) {
  (function() {
    var BaseView,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    BaseView = require('lib/base_view');

    exports.MailboxForm = (function(_super) {

      __extends(MailboxForm, _super);

      function MailboxForm() {
        MailboxForm.__super__.constructor.apply(this, arguments);
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
        if ($(event.target).hasClass("disabled")) return false;
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
        this.model.save(data, {
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
        return app.router.navigate('config/mailboxes', true);
      };

      return MailboxForm;

    })(BaseView);

  }).call(this);
  
});
window.require.register("views/mails_list", function(exports, require, module) {
  (function() {
    var FolderMenu, ViewCollection,
      __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

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
        this.stopSpinContainer = __bind(this.stopSpinContainer, this);
        this.spinContainer = __bind(this.spinContainer, this);
        MailsList.__super__.constructor.apply(this, arguments);
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
        this.listenTo(app.mailboxes, 'change:color', this.updateColors);
        this.listenTo(app.mailboxes, 'add', this.updateColors);
        this.listenTo(app.mails, 'request', this.spinContainer);
        this.listenTo(app.mails, 'sync', this.stopSpinContainer);
        this.foldermenu = new FolderMenu({
          collection: app.folders
        });
        return this.foldermenu.render();
      };

      MailsList.prototype.itemViewOptions = function() {
        return {
          folderId: this.collection.folderId
        };
      };

      MailsList.prototype.checkIfEmpty = function() {
        var empty;
        MailsList.__super__.checkIfEmpty.apply(this, arguments);
        empty = _.size(this.views) === 0;
        this.$('#markallread-btn').toggle(!empty);
        this.$('#add_more_mails').toggle(!empty);
        return this.$('#refresh-btn').toggle(!empty);
      };

      MailsList.prototype.afterRender = function() {
        this.noMailMsg = this.$('#no-mails-message');
        this.noMailMsg.hide();
        this.loadmoreBtn = this.$('#add_more_mails');
        this.container = this.$('#mails_list_container');
        this.$('#topbar').append(this.foldermenu.$el);
        if (this.activated) this.activate(this.activated);
        this.$el.niceScroll();
        return MailsList.__super__.afterRender.apply(this, arguments);
      };

      MailsList.prototype.remove = function() {
        this.$el.getNiceScroll().remove();
        return MailsList.__super__.remove.apply(this, arguments);
      };

      MailsList.prototype.appendView = function(view) {
        var dateValueOf;
        if (!this.container) return;
        dateValueOf = view.model.get('dateValueOf');
        if (dateValueOf < this.collection.timestampNew) {
          if (dateValueOf < this.collection.timestampOld) {
            this.collection.timestampOld = dateValueOf;
            this.collection.lastIdOld = view.model.id;
          }
          this.container.append(view.$el);
        } else {
          if (dateValueOf >= this.collection.timestampNew) {
            this.collection.timestampNew = dateValueOf;
            this.collection.lastIdNew = view.model.id;
          }
          this.container.prepend(view.$el);
        }
        return this.$el.getNiceScroll().resize();
      };

      MailsList.prototype.refresh = function() {
        var btn, promise,
          _this = this;
        btn = this.$('#refresh-btn');
        btn.spin('small').addClass('disabled');
        promise = $.ajax('mails/fetch-new/');
        promise.error(function(jqXHR, error) {
          btn.text('Retry').addClass('error');
          return alert("Connection Error : " + (error.message || error));
        });
        promise.success(function() {
          btn.text('Refresh').removeClass('error');
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
        var oldlength, promise,
          _this = this;
        if (this.loadmoreBtn.hasClass('disabled')) return null;
        oldlength = this.collection.length;
        this.loadmoreBtn.addClass("disabled").text("Loading...");
        promise = this.collection.fetchOlder();
        promise.always(function() {
          return _this.loadmoreBtn.removeClass('disabled').text("more messages");
        });
        return promise.done(function() {
          if (_this.collection.length === oldlength) return _this.loadmoreBtn.hide();
        });
      };

      MailsList.prototype.spinContainer = function() {
        var _ref;
        return (_ref = this.container) != null ? _ref.spin() : void 0;
      };

      MailsList.prototype.stopSpinContainer = function() {
        var _ref, _ref2;
        if ((_ref = this.container) != null) _ref.spin(false);
        return (_ref2 = this.noMailMsg) != null ? _ref2.toggle(_.size(this.views) === 0) : void 0;
      };

      MailsList.prototype.updateColors = function() {
        var id, view, _ref, _results;
        _ref = this.views;
        _results = [];
        for (id in _ref) {
          view = _ref[id];
          _results.push(view.render());
        }
        return _results;
      };

      MailsList.prototype.activate = function(id) {
        var cid, view, _ref, _results;
        this.activated = id;
        _ref = this.views;
        _results = [];
        for (cid in _ref) {
          view = _ref[cid];
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

  }).call(this);
  
});
window.require.register("views/mails_list_element", function(exports, require, module) {
  
  /*
      @file: mails_list_element.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description:
          The element on the list of mails. Reacts for events, and stuff.
  */

  (function() {
    var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    exports.MailsListElement = (function(_super) {

      __extends(MailsListElement, _super);

      function MailsListElement() {
        this.href = __bind(this.href, this);
        MailsListElement.__super__.constructor.apply(this, arguments);
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
        this.listenTo(this.model, 'change', this.render);
        return this.folderId = this.options.folderId;
      };

      MailsListElement.prototype.setActiveMail = function(event) {
        $(".table tr").removeClass("active");
        this.$el.addClass("active");
        if (!this.model.isRead()) {
          this.model.markRead();
          this.model.save();
        }
        return window.app.router.navigate(this.href(), true);
      };

      MailsListElement.prototype.href = function() {
        var base;
        base = this.folderId === 'rainbow' ? 'rainbow/' : "folder/" + this.folderId + "/";
        return base + ("mail/" + (this.model.get('id')));
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
        var data, mailboxname, template, _ref;
        mailboxname = ((_ref = this.model.getMailbox()) != null ? _ref.get('name') : void 0) || '';
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

  }).call(this);
  
});
window.require.register("views/mails_list_more", function(exports, require, module) {
  (function() {
    var Mail,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

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
            if (nbMails === 0) return $(_this.el).hide();
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

  }).call(this);
  
});
window.require.register("views/menu", function(exports, require, module) {
  (function() {
    var BaseView,
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    BaseView = require('lib/base_view');

    exports.Menu = (function(_super) {

      __extends(Menu, _super);

      function Menu() {
        Menu.__super__.constructor.apply(this, arguments);
      }

      Menu.prototype.id = 'menu_container';

      Menu.prototype.template = require('templates/menu');

      Menu.prototype.select = function(activeid) {
        this.$(".menu_option").removeClass("active");
        return this.$("#" + activeid).addClass("active");
      };

      return Menu;

    })(BaseView);

  }).call(this);
  
});
window.require.register("views/message_box", function(exports, require, module) {
  (function() {
    var LogMessage, MessageBoxElement,
      __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

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

  }).call(this);
  
});
window.require.register("views/message_box_element", function(exports, require, module) {
  
  /*
      @file: message_box_element.coffee
      @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
      @description:
          Serves a single message to user
  */

  (function() {
    var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

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

  }).call(this);
  
});
window.require.register("views/modal", function(exports, require, module) {
  (function() {
    var BaseView,
      __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
      __hasProp = Object.prototype.hasOwnProperty,
      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

    BaseView = require('lib/base_view');

    exports.Modal = (function(_super) {

      __extends(Modal, _super);

      function Modal() {
        this.showAndThen = __bind(this.showAndThen, this);
        this.events = __bind(this.events, this);
        Modal.__super__.constructor.apply(this, arguments);
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

  }).call(this);
  
});

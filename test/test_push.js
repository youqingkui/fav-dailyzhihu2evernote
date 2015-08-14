// Generated by CoffeeScript 1.8.0
(function() {
  var CheckAdd, PushEvernote, Task, async, j1, j2, noteStore, rule1, rule2, schedule, token, txErr;

  PushEvernote = require('../lib/pushEvernote');

  Task = require('../models/tasks');

  async = require('async');

  txErr = require('../lib/txErr');

  noteStore = require('../lib/noteStore');

  schedule = require("node-schedule");

  token = process.env.daily_zhihu;

  CheckAdd = require('../lib/checkAdd');

  rule1 = new schedule.RecurrenceRule();

  rule1.dayOfWeek = [0, new schedule.Range(1, 6)];

  rule1.hour = 20;

  rule1.minute = 25;

  rule2 = new schedule.RecurrenceRule();

  rule2.dayOfWeek = [0, new schedule.Range(1, 6)];

  rule2.hour = 20;

  rule2.minute = 27;

  j1 = schedule.scheduleJob(rule1, function() {
    var ca;
    ca = new CheckAdd(token);
    return async.waterfall([
      function(cb) {
        return ca.getList(function(err, data) {
          if (err) {
            return console.log(err);
          }
          return cb(null, data);
        });
      }, function(data, cb) {
        return ca.checkUP(data, function(err) {
          if (err) {
            return console.log(err);
          }
          return console.log("#check all do#");
        });
      }
    ]);
  });

  j2 = schedule.scheduleJob(rule2, function() {
    return async.waterfall([
      function(cb) {
        return Task.find({
          status: 1
        }, null, {
          sort: {
            _id: -1
          }
        }, function(err, rows) {
          var i, _i, _len;
          if (err) {
            return txErr(op.url, {
              err: err,
              fun: 'getList-find'
            });
          }
          for (_i = 0, _len = rows.length; _i < _len; _i++) {
            i = rows[_i];
            console.log(i);
          }
          return cb(null, rows);
        });
      }, function(tasks, cb) {
        return async.eachSeries(tasks, function(item, callback) {
          var p;
          p = new PushEvernote(noteStore, '', item.url, item.id, item.title);
          return p.pushNote(callback);
        }, function() {
          console.log("all do");
          return console.log("all do");
        });
      }
    ]);
  });

}).call(this);

//# sourceMappingURL=test_push.js.map

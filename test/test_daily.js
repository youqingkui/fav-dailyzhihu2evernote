// Generated by CoffeeScript 1.8.0
(function() {
  var CheckDaily, Daily, PushDaily, async, j, noteStore, rule, schedule, tx;

  PushDaily = require('../lib/pushDaily');

  Daily = require('../models/daily');

  async = require('async');

  tx = require('../lib/txErr');

  noteStore = require('../lib/noteStore');

  schedule = require("node-schedule");

  CheckDaily = require('../lib/checkDaily');

  rule = new schedule.RecurrenceRule();

  rule.minute = 50;

  j = schedule.scheduleJob(rule, function() {
    return async.waterfall([
      function(cb) {
        var check;
        check = new CheckDaily();
        return check.doTask(cb);
      }, function(cb) {
        return Daily.find({
          status: 0
        }, null, {
          sort: {
            _id: -1
          }
        }, function(err, rows) {
          if (err) {
            return txErr(op.url, {
              err: err,
              fun: 'getList-find'
            });
          }
          return cb(null, rows);
        });
      }, function(tasks, cb) {
        return async.eachSeries(tasks, function(item, callback) {
          var p;
          p = new PushDaily(noteStore, 'af0137f4-89c6-4ad1-9bde-758bdcf378c1', item.url, item.href, item.title);
          return p.pushNote(callback);
        }, function() {
          return console.log("all do");
        });
      }
    ]);
  });

}).call(this);

//# sourceMappingURL=test_daily.js.map

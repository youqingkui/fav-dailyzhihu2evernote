// Generated by CoffeeScript 1.8.0
(function() {
  var DailySchema, mongoose;

  mongoose = require('./mongoose');

  DailySchema = mongoose.Schema({
    href: {
      type: String,
      unique: true
    },
    url: {
      type: String,
      unique: true
    },
    guid: {
      type: String
    },
    title: {
      type: String
    },
    status: {
      type: Number,
      "default": 0
    },
    createTime: {
      type: Date,
      "default": Date.now
    }
  });

  DailySchema["static"].checkSame = function(id, cb) {
    return DailySchema.findOne({
      id: id
    }, function(err, row) {
      if (err) {
        return cb(err);
      }
      if (row) {
        return cb(row);
      } else {
        return cb();
      }
    });
  };

  module.exports = mongoose.model('Daily', DailySchema);

}).call(this);

//# sourceMappingURL=daily.js.map

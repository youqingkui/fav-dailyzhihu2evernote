// Generated by CoffeeScript 1.8.0
(function() {
  var TaskSchema, mongoose;

  mongoose = require('./mongoose');

  TaskSchema = mongoose.Schema({
    id: {
      type: Number,
      unique: true
    },
    title: {
      type: String
    },
    url: {
      type: String,
      unique: true
    },
    status: {
      type: Number,
      "default": 1
    }
  });

  module.exports = mongoose.model('Task', TaskSchema);

}).call(this);

//# sourceMappingURL=tasks.js.map
// models/Condition.js
const mongoose = require('mongoose');

const conditionSchema = new mongoose.Schema({
  text: {
    type: String,
    required: true
  },
});

module.exports = mongoose.model('Condition', conditionSchema);

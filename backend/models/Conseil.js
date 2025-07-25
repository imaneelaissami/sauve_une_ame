const mongoose = require('mongoose');

const ConseilSchema = new mongoose.Schema({
  titre: String,
  contenu: String,
});

module.exports = mongoose.model('Conseil', ConseilSchema);

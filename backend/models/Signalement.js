// models/Signalement.js
const mongoose = require('mongoose');

const SignalementSchema = new mongoose.Schema({
  image: { type: String, required: true },        // مسار الصورة على السيرفر
  typeAnimal: { type: String, required: true },         // نوع الحيوان (chien, chat, autre)
  description: { type: String, required: true },
  adresse: { type: String, required: true },
  phone: { type: String, required: true },
  latitude: { type: String, required: true },
  longitude: { type: String, required: true },
  fullName: { type: String, required: true },
  email: { type: String, required: true },
  userType: { type: String, required: true },
  dateSignalement: { type: Date, default: Date.now }
});


module.exports = mongoose.model('Signalement', SignalementSchema);

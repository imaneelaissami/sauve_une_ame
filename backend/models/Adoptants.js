const mongoose = require('mongoose');

const adoptantSchema = new mongoose.Schema({
  type: { type: String, required: true },       // Chien أو Chat
  sex: { type: String, required: true },        // ذكر أو أنثى

  description: { type: String, required: true },
  probleme: { type: String },                     // مرض أو إعاقة (اختياري)
  image: { type: String, required: true },       // مسار الصورة
  fullName: { type: String, required: true },
  email: { type: String, required: true },
  phone: { type: String, required: true },
  userType: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Adoptant', adoptantSchema, 'adoptants');

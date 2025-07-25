const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const userSchema = new mongoose.Schema({
  fullName: {
    type: String,
    required: true
  },
  email: {
    type: String,
    required: true,
    unique: true // ✅ باش مايتسجلوش نفس الإيميل مرّتين
  },
  sex: {
    type: String,
    enum: ['Homme', 'Femme'],
    required: true
  },
  age: {
    type: Number,
    required: true
  },
  city: {
    type: String,
    required: true
  },
  country: {
    type: String,
    required: true
  },

  phone: {
    type: String,
    required: true
  },
  password: {
    type: String,
    required: true
  },
  userType: {
    type: String,
    enum: ['normalUser', 'adoptantUser', 'sauveteurUser','superadmin'], // ✅ تحديد الأنواع فقط
    default: 'normalUser'
  },
  profileImage: {
    type: String
  }

}, { timestamps: true });
// ✅ تشفير كلمة السر قبل الحفظ
userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();

  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (err) {
    next(err);
  }
});



module.exports = mongoose.model('User', userSchema);

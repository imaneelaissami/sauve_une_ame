const express = require('express');
const router = express.Router();
const multer = require('multer');
const bcrypt = require('bcrypt');
const User = require('../models/User');

router.post('/getUserByEmail', async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) return res.status(400).json({ message: 'Email is required' });

    const user = await User.findOne({ email }).lean();

    if (!user) return res.status(404).json({ message: 'User not found' });

    res.json({ user });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// إعداد multer لتخزين الصور
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');  // مجلد تخزين الصور (خاصك تخلق هاد المجلد)
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + '-' + file.originalname);
  }
});
const upload = multer({ storage: storage });

router.put('/update', upload.single('profileImage'), async (req, res) => {
 console.log('Fichier reçu:', req.file);
  console.log('Body reçu:', req.body);
  const { email, fullName, phone, sex, age, city, country, password } = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ error: 'Utilisateur non trouvé' });

    user.fullName = fullName;
    user.phone = phone;
    user.sex = sex;
    user.age = age;
    user.city = city;
    user.country = country;

    if (password && password.trim() !== '') {

      user.password = await bcrypt.hash(password, 10); // ✅ تشفير كلمة السر
    }
      if (req.file) {
          user.profileImage = `/uploads/${req.file.filename}`;
        }

        await user.save();

        res.json({ success: true, message: "✅ Profil mis à jour", user });
      } catch (error) {
        console.error(error);
        if (error.code === 11000 && error.keyPattern.email) {
          return res.status(400).json({ error: '❌ Email déjà utilisé', details: 'Cet email est déjà enregistré' });
        }
        res.status(500).json({ error: '❌ Registration failed', details: error.message });
      }
    });

// ✅ Route: POST /api/users/register مع رفع صورة بملف profileImage

router.post('/register', upload.single('profileImage'), async (req, res) => {
  try {
    const { fullName, email, password, phone, userType, sex, age,city, country } = req.body;
    let profileImage = '';

    if (req.file) {
      profileImage = `/uploads/${req.file.filename}`; // رابط الصورة النسبي
    }
    //const hashedPassword = await bcrypt.hash(password, 10); // تشفير كلمة السر
    //const saltRounds = 10;


    // إنشاء المستخدم مع رابط الصورة
    const user = new User({
      fullName,
      email,
      password, // نصيحة: تشفير كلمة السر قبل الحفظ (مثلاً bcrypt)
      phone,
      sex,
      age,
      city,
      country,
      userType,
      profileImage,
    });

    await user.save();
    res.status(201).json({ message: '✅ User registered successfully', user });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: '❌ Registration failed', details: error.message });
  }
});
// GET /api/users  => جلب جميع المستخدمين
router.get('/', async (req, res) => {
  try {
    const users = await User.find().lean();
    res.json(users);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur serveur lors de la récupération des utilisateurs' });
  }
});
// حذف مستخدم عبر البريد الإلكتروني
router.delete('/', async (req, res) => {
  const email = req.query.email;
  if (!email) return res.status(400).json({ message: 'Email is required for deletion' });

  try {
    const deletedUser = await User.findOneAndDelete({ email });
    if (!deletedUser) return res.status(404).json({ message: 'User not found' });

    res.json({ message: 'User deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error during deletion' });
  }
});



// ✅ Route: POST /api/users/login

router.post('/login', async (req, res) => {
console.log('Received login data:', req.body);
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(401).json({ message: '❌ Email introuvable' });
    }

   const isMatch = await bcrypt.compare(password, user.password);
   if (!isMatch) {
     return res.status(401).json({ message: '❌ Mot de passe incorrect' });
   }

    res.json({
      message: '✅ Connexion réussie',
      user: {
        id: user._id,
        fullName: user.fullName,
        email: user.email,
         sex: user.sex,
         age: user.age,
         city: user.city,
         country: user.country,
        phone: user.phone,
        userType: user.userType,
        profileImage: user.profileImage ||  '',  // إضافة رابط الصورة هنا
      },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: '❌ Erreur serveur', details: err.message });
  }
});

module.exports = router;

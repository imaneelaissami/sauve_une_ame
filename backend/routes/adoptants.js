const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const Adoptant = require('../models/Adoptants');

// إعداد تخزين الصور
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');  // تأكد أن المجلد uploads موجود
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  }
});
const upload = multer({ storage: storage });

/**
 * 📤 POST /api/adoptants/create
 * نشر حيوان للتبني
 */
router.post('/create', upload.single('image'), async (req, res) => {
  try {
    const { type, sex, description, probleme, fullName, email, phone, userType } = req.body;

    if (!req.file) {
      return res.status(400).json({ error: 'Image est obligatoire' });
    }

    const newAdoptant = new Adoptant({
      type,
      sex,
      description,
      probleme,
      image: `/uploads/${req.file.filename}`,
      fullName,
      email,
      phone,
      userType,
    });

    await newAdoptant.save();
    res.status(200).json({ message: 'Animal publié avec succès', adoptant: newAdoptant });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

/**
 * 📥 GET /api/adoptants
 * جلب جميع الحيوانات المعروضة للتبني
 */
router.get('/', async (req, res) => {
  try {
    const adoptants = await Adoptant.find().sort({ createdAt: -1 }); // ترتيب حسب الأحدث
    res.status(200).json(adoptants);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur lors de la récupération des adoptants' });
  }
});
// DELETE animal
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    await Adoptant.findByIdAndDelete(id);
    res.status(200).json({ message: 'Animal supprimé avec succès' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});
/**
 * ✏️ PUT /api/adoptants/:id
 * تعديل بيانات حيوان معين
 */
router.put('/:id', upload.single('image'), async (req, res) => {
  try {
    const { id } = req.params;

    // بيانات التعديل من body (type, sex, description, etc)
    const { type, sex, description, probleme, fullName, email, phone, userType } = req.body;

    // بناء كائن التعديل
    const updateData = {
      type,
      sex,
      description,
      probleme,
      fullName,
      email,
      phone,
      userType,
    };

    // إذا تم إرسال صورة جديدة، نحدث مسار الصورة
    if (req.file) {
      updateData.image = `/uploads/${req.file.filename}`;
    }

    // تحديث المستند
    const updatedAdoptant = await Adoptant.findByIdAndUpdate(id, updateData, { new: true });

    if (!updatedAdoptant) {
      return res.status(404).json({ error: 'Animal non trouvé' });
    }

    res.status(200).json({ message: 'Animal modifié avec succès', adoptant: updatedAdoptant });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur serveur lors de la modification' });
  }
});


module.exports = router;

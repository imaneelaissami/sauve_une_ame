const express = require('express');
const router = express.Router();
const Signalement = require('../models/Signalement');
const multer = require('multer');
const path = require('path');


const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, './uploads/');
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});

const upload = multer({ storage: storage });

router.post('/signalAnimal', upload.single('image'), async (req, res) => {
  try {
    const {
      typeAnimal,
      description,
      adresse,
      phone,
      latitude,
      longitude,
      fullName,
      email,
      userType
    } = req.body;

    if (!req.file) {
      return res.status(400).json({ message: 'Image est requise.' });
    }

    const newSignalement = new Signalement({
      image: `/uploads/${req.file.filename}`,
      typeAnimal,
      description,
      adresse,
      phone,
      latitude,
      longitude,
      fullName,
      email,
      userType
    });

    await newSignalement.save();

    res.status(200).json({ message: 'Signalement enregistré avec succès' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});
// ✅ PUT: تعديل signalement عبر ID
router.put('/signalements/:id', upload.single('image'), async (req, res) => {
  try {
    const signalementId = req.params.id;

    const {
      typeAnimal,
      description,
      adresse,
      phone,
      latitude,
      longitude,
      fullName,
      email,
      userType,
    } = req.body;

    const updateFields = {
      typeAnimal,
      description,
      adresse,
      phone,
      latitude,
      longitude,
      fullName,
      email,
      userType,
    };


    if (req.file) {
      updateFields.image = `/uploads/${req.file.filename}`;
    }

    const updated = await Signalement.findByIdAndUpdate(
      signalementId,
      updateFields,
      { new: true }
    );

    if (!updated) {
      return res.status(404).json({ message: 'Signalement introuvable' });
    }

    res.status(200).json({ message: 'Signalement mis à jour avec succès', data: updated });

  } catch (error) {
    console.error('Erreur PUT:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});



// ✅ 2. مسار GET: جلب signalements حسب النوع
router.get('/signalements', async (req, res) => {
  try {
    const typeAnimal = req.query.type; // ?type=Chat أو ?type=Chien

    const filter = {};
    if (typeAnimal) {
      filter.typeAnimal = typeAnimal;
    }

    const signalements = await Signalement.find(filter).sort({ dateSignalement: -1 });

    res.status(200).json(signalements);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// ✅ DELETE: حذف حيوان مبلّغ عنه عبر ID
router.delete('/signalements/:id', async (req, res) => {
  try {
    const signalementId = req.params.id;
    await Signalement.findByIdAndDelete(signalementId);
    res.status(200).json({ message: 'Signalement supprimé avec succès' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur lors de la suppression' });
  }
});

// جلب كل signalements الخاصة بمستخدم معين حسب البريد الإلكتروني
router.get('/signalements/:email', async (req, res) => {
  try {
    const email = req.params.email;
    const signalements = await Signalement.find({ email }).sort({ dateSignalement: -1 });
    res.status(200).json(signalements);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});



// ✅ مهم: تصدير الراوتر
module.exports = router;

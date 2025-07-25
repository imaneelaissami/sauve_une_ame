const express = require('express');
const router = express.Router();
const Conseil = require('../models/Conseil');

// Ajouter un conseil
router.post('/', async (req, res) => {
  try {
    const newConseil = new Conseil(req.body);
    await newConseil.save();
    res.status(201).json(newConseil);
  } catch (err) {
    res.status(500).json(err);
  }
});

// Obtenir tous les conseils
router.get('/', async (req, res) => {
  try {
    const conseils = await Conseil.find();
    res.status(200).json(conseils);
  } catch (err) {
    res.status(500).json(err);
  }
});

// Supprimer un conseil
router.delete('/:id', async (req, res) => {
  try {
    await Conseil.findByIdAndDelete(req.params.id);
    res.status(200).json({ message: 'Conseil supprimé' });
  } catch (err) {
    res.status(500).json(err);
  }
});

// Modifier un conseil
router.put('/:id', async (req, res) => {
  try {
    const updated = await Conseil.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.status(200).json(updated);
  } catch (err) {
    res.status(500).json(err);
  }
});

module.exports = router;

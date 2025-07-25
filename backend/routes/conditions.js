const express = require('express');
const router = express.Router();
const Condition = require('../models/Condition'); // ✅ هنا خدم بالموديل مباشرة

// GET toutes les conditions
router.get('/', async (req, res) => {
  const conditions = await Condition.find();
  res.json(conditions);
});

// POST nouvelle condition
router.post('/', async (req, res) => {
  const newCondition = new Condition({ text: req.body.text });
  await newCondition.save();
  res.json({ message: 'Condition ajoutée avec succès' });
});

// PUT modifier une condition
router.put('/:id', async (req, res) => {
  await Condition.findByIdAndUpdate(req.params.id, { text: req.body.text });
  res.json({ message: 'Condition modifiée' });
});

// DELETE supprimer une condition
router.delete('/:id', async (req, res) => {
  await Condition.findByIdAndDelete(req.params.id);
  res.json({ message: 'Condition supprimée' });
});

module.exports = router;

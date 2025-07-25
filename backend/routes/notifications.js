const express = require('express');
const router = express.Router();
const Notification = require('../models/Notification');

router.post('/sendNotification', async (req, res) => {
  try {
    const { email, message } = req.body;

    const notif = new Notification({ email, message });
    await notif.save();

    res.status(200).json({ success: true, message: 'Notification envoyée' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Erreur', error: err });
  }
});



// جلب جميع النوتيفيكاشنز الخاصة بإيميل معيّن
router.get('/:email', async (req, res) => {
  try {
    const email = req.params.email;
    const notifications = await Notification.find({ email });
    res.status(200).json(notifications);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
// DELETE notification by id
router.delete('/:id', async (req, res) => {
  try {
    const id = req.params.id;
    const deleted = await Notification.findByIdAndDelete(id);

    if (!deleted) {
      return res.status(404).json({ success: false, message: 'Notification non trouvée' });
    }

    res.status(200).json({ success: true, message: 'Notification supprimée' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Erreur lors de la suppression', error: err.message });
  }
});


module.exports = router;

const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());
app.use('/uploads', express.static('uploads'));

mongoose.connect('mongodb://127.0.0.1:27017/sauver_une_ame', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('✅ Connecté à MongoDB'))
.catch((err) => console.error('❌ Erreur MongoDB:', err));

const userRoutes = require('./routes/user');
const signalementRoutes = require('./routes/signalement');
const adoptantsRoutes = require('./routes/adoptants');  // استيراد route adoptants
const notificationRoutes = require('./routes/notifications');
const conditionRoutes = require('./routes/conditions');
const conseilsRoute = require('./routes/conseils');

app.use('/api/users', userRoutes);
app.use('/api/signal', signalementRoutes);
app.use('/api/adoptants', adoptantsRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/conditions', conditionRoutes);
app.use('/api/conseils', conseilsRoute);
app.get('/', (req, res) => {
  res.send('Backend is working! ✅');
});

app.listen(port, () => {
  console.log(`🚀 Serveur backend lancé sur http://localhost:${port}`);
});

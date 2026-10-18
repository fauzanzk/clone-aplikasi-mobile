const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '../.env') });

const authRoutes = require('./routes/authRoutes');
const airportRoutes = require('./routes/airportRoutes');
const flightRoutes = require('./routes/flightRoutes');
const hotelRoutes = require('./routes/hotelRoutes');
const trainRoutes = require('./routes/trainRoutes');
const serviceRoutes = require('./routes/serviceRoutes');
const bookingRoutes = require('./routes/bookingRoutes');
const wishlistRoutes = require('./routes/wishlistRoutes');
const { getCities } = require('./controllers/airportController');
const { getStations } = require('./controllers/trainController');
const { getProfile, updateProfile } = require('./controllers/authController');
const { authMiddleware } = require('./middleware/auth');
const db = require('./config/db');

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/', (req, res) => {
  res.json({
    status: 'online',
    app: 'TraveLokuy API Server',
    version: '1.0.0',
    documentation: 'See MVP-TraveLoka.md'
  });
});

app.get('/health', async (req, res) => {
  try {
    await db.query('SELECT 1');
    res.json({ status: 'healthy', database: 'connected' });
  } catch (err) {
    res.status(500).json({ status: 'unhealthy', database: 'disconnected', error: err.message });
  }
});

// Routes
app.use('/auth', authRoutes);
app.use('/airports', airportRoutes);
app.get('/cities', getCities);
app.get('/stations', getStations);
app.use('/flights', flightRoutes);
app.use('/hotels', hotelRoutes);
app.use('/trains', trainRoutes);
app.use('/services', serviceRoutes);
app.use('/bookings', bookingRoutes);
app.use('/wishlist', wishlistRoutes);

// Profile endpoint (/me)
app.get('/me', authMiddleware, getProfile);
app.put('/me', authMiddleware, updateProfile);

// Periodic booking expiration runner (every 60 seconds)
setInterval(async () => {
  try {
    const [expiredList] = await db.query(
      `SELECT b.id, b.type, fb.flight_id, fb.seats
       FROM bookings b
       LEFT JOIN flight_bookings fb ON fb.booking_id = b.id
       WHERE b.status = 'PENDING' AND b.expires_at < NOW()`
    );

    for (const exp of expiredList) {
      await db.query("UPDATE bookings SET status = 'EXPIRED' WHERE id = ?", [exp.id]);
      if (exp.type === 'FLIGHT' && exp.flight_id && exp.seats) {
        await db.query('UPDATE flights SET seats_available = seats_available + ? WHERE id = ?', [
          exp.seats,
          exp.flight_id
        ]);
      }
      console.log(`[EXPIRATION] Booking ID ${exp.id} has expired and status updated.`);
    }
  } catch (e) {
    // Suppress background tick error
  }
}, 60000);

// Global Error Handler
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({
    success: false,
    message: 'Terjadi kesalahan internal server.',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// 404 Route
app.use((req, res) => {
  res.status(404).json({ success: false, message: `Route ${req.method} ${req.url} tidak ditemukan.` });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`===============================================`);
  console.log(`✈️  TraveLokuy API Server running on port ${PORT}`);
  console.log(`📡 URL: http://localhost:${PORT}`);
  console.log(`===============================================`);
});

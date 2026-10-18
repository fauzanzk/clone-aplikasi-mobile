const db = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const register = async (req, res) => {
  try {
    const { name, email, phone, password } = req.body;
    if (!name || !email || !password) {
      return res.status(400).json({ success: false, message: 'Nama, email, dan password wajib diisi.' });
    }

    const [existing] = await db.query('SELECT id FROM users WHERE email = ?', [email]);
    if (existing.length > 0) {
      return res.status(400).json({ success: false, message: 'Email sudah terdaftar. Silakan login.' });
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    const [result] = await db.query(
      'INSERT INTO users (name, email, phone, password_hash) VALUES (?, ?, ?, ?)',
      [name, email, phone || null, passwordHash]
    );

    const userId = result.insertId;
    const token = jwt.sign(
      { id: userId, email, name },
      process.env.JWT_SECRET || 'traveloka_super_secret_jwt_key_2026_id',
      { expiresIn: '7d' }
    );

    return res.status(201).json({
      success: true,
      message: 'Registrasi berhasil!',
      data: {
        token,
        user: { id: userId, name, email, phone }
      }
    });
  } catch (err) {
    console.error('Register error:', err);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan pada server.' });
  }
};

const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Email dan password wajib diisi.' });
    }

    const [rows] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
    if (rows.length === 0) {
      return res.status(401).json({ success: false, message: 'Email atau password salah.' });
    }

    const user = rows[0];
    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Email atau password salah.' });
    }

    const token = jwt.sign(
      { id: user.id, email: user.email, name: user.name },
      process.env.JWT_SECRET || 'traveloka_super_secret_jwt_key_2026_id',
      { expiresIn: '7d' }
    );

    return res.json({
      success: true,
      message: 'Login berhasil!',
      data: {
        token,
        user: { id: user.id, name: user.name, email: user.email, phone: user.phone }
      }
    });
  } catch (err) {
    console.error('Login error:', err);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan pada server.' });
  }
};

const getProfile = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT id, name, email, phone, created_at FROM users WHERE id = ?', [req.user.id]);
    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'User tidak ditemukan.' });
    }

    const [bookingStats] = await db.query(
      `SELECT 
         COUNT(*) as total_bookings,
         SUM(CASE WHEN status = 'PAID' THEN 1 ELSE 0 END) as active_bookings,
         SUM(CASE WHEN status = 'PENDING' THEN 1 ELSE 0 END) as pending_bookings
       FROM bookings WHERE user_id = ?`,
      [req.user.id]
    );

    const [wishlistCount] = await db.query('SELECT COUNT(*) as count FROM wishlists WHERE user_id = ?', [req.user.id]);

    return res.json({
      success: true,
      data: {
        user: rows[0],
        stats: {
          ...bookingStats[0],
          wishlist_count: wishlistCount[0].count
        }
      }
    });
  } catch (err) {
    console.error('Get profile error:', err);
    return res.status(500).json({ success: false, message: 'Gagal mengambil profil.' });
  }
};

const updateProfile = async (req, res) => {
  try {
    const { name, phone } = req.body;
    await db.query('UPDATE users SET name = COALESCE(?, name), phone = COALESCE(?, phone) WHERE id = ?', [
      name,
      phone,
      req.user.id
    ]);

    const [rows] = await db.query('SELECT id, name, email, phone FROM users WHERE id = ?', [req.user.id]);
    return res.json({
      success: true,
      message: 'Profil berhasil diperbarui.',
      data: rows[0]
    });
  } catch (err) {
    console.error('Update profile error:', err);
    return res.status(500).json({ success: false, message: 'Gagal memperbarui profil.' });
  }
};

module.exports = { register, login, getProfile, updateProfile };

const db = require('../config/db');

const addReview = async (req, res) => {
  try {
    const { id } = req.params; // hotel_id
    const { rating, comment } = req.body;
    const userId = req.user.id;

    if (!rating || rating < 1 || rating > 5) {
      return res.status(400).json({ success: false, message: 'Rating harus antara 1 sampai 5 bintang.' });
    }

    await db.query(
      `INSERT INTO reviews (hotel_id, user_id, rating, comment) VALUES (?, ?, ?, ?)`,
      [id, userId, rating, comment || '']
    );

    // Recalculate hotel average rating
    const [avg] = await db.query(
      'SELECT AVG(rating) as avg_rating FROM reviews WHERE hotel_id = ?',
      [id]
    );

    if (avg.length > 0 && avg[0].avg_rating) {
      await db.query('UPDATE hotels SET rating = ? WHERE id = ?', [
        parseFloat(avg[0].avg_rating).toFixed(1),
        id
      ]);
    }

    return res.status(201).json({
      success: true,
      message: 'Ulasan Anda berhasil ditambahkan. Terima kasih!'
    });
  } catch (err) {
    console.error('Add review error:', err);
    return res.status(500).json({ success: false, message: 'Gagal menambahkan ulasan.' });
  }
};

module.exports = { addReview };

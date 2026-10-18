const db = require('../config/db');

const getWishlist = async (req, res) => {
  try {
    const userId = req.user.id;
    const [rows] = await db.query(
      `SELECT 
        h.id, h.name, h.city_id, h.address, h.star, h.description, 
        h.facilities, h.image_url, h.rating,
        c.name AS city_name,
        MIN(rt.price_per_night) AS start_price
       FROM wishlists w
       JOIN hotels h ON w.hotel_id = h.id
       JOIN cities c ON h.city_id = c.id
       JOIN room_types rt ON rt.hotel_id = h.id
       WHERE w.user_id = ?
       GROUP BY h.id`,
      [userId]
    );

    const formatted = rows.map(r => {
      let facilities = [];
      try {
        facilities = typeof r.facilities === 'string' ? JSON.parse(r.facilities) : r.facilities;
      } catch (e) {
        facilities = [];
      }
      return { ...r, facilities, is_wishlist: true };
    });

    return res.json({ success: true, count: formatted.length, data: formatted });
  } catch (err) {
    console.error('Get wishlist error:', err);
    return res.status(500).json({ success: false, message: 'Gagal mengambil daftar wishlist.' });
  }
};

const toggleWishlist = async (req, res) => {
  try {
    const userId = req.user.id;
    const { hotelId } = req.params;

    const [existing] = await db.query(
      'SELECT 1 FROM wishlists WHERE user_id = ? AND hotel_id = ?',
      [userId, hotelId]
    );

    if (existing.length > 0) {
      await db.query('DELETE FROM wishlists WHERE user_id = ? AND hotel_id = ?', [userId, hotelId]);
      return res.json({ success: true, message: 'Hotel dihapus dari wishlist.', is_wishlist: false });
    } else {
      await db.query('INSERT INTO wishlists (user_id, hotel_id) VALUES (?, ?)', [userId, hotelId]);
      return res.json({ success: true, message: 'Hotel ditambahkan ke wishlist!', is_wishlist: true });
    }
  } catch (err) {
    console.error('Toggle wishlist error:', err);
    return res.status(500).json({ success: false, message: 'Gagal memperbarui wishlist.' });
  }
};

const removeWishlist = async (req, res) => {
  try {
    const userId = req.user.id;
    const { hotelId } = req.params;

    await db.query('DELETE FROM wishlists WHERE user_id = ? AND hotel_id = ?', [userId, hotelId]);
    return res.json({ success: true, message: 'Hotel dihapus dari wishlist.', is_wishlist: false });
  } catch (err) {
    console.error('Remove wishlist error:', err);
    return res.status(500).json({ success: false, message: 'Gagal menghapus dari wishlist.' });
  }
};

module.exports = { getWishlist, toggleWishlist, removeWishlist };

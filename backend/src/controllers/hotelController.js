const db = require('../config/db');

const searchHotels = async (req, res) => {
  try {
    const { city, checkin, checkout, guests, star, sortBy } = req.query;
    const guestCount = parseInt(guests || '1', 10);

    let query = `
      SELECT 
        h.id, h.name, h.city_id, h.address, h.star, h.description, 
        h.facilities, h.image_url, h.rating,
        c.name AS city_name, c.country,
        MIN(rt.price_per_night) AS start_price,
        COUNT(DISTINCT rev.id) AS total_reviews
      FROM hotels h
      JOIN cities c ON h.city_id = c.id
      JOIN room_types rt ON rt.hotel_id = h.id
      LEFT JOIN reviews rev ON rev.hotel_id = h.id
      WHERE 1=1
    `;
    const params = [];

    // City filter (ID or Name)
    if (city) {
      if (!isNaN(city)) {
        query += ` AND h.city_id = ?`;
        params.push(parseInt(city, 10));
      } else {
        query += ` AND (c.name LIKE ? OR h.address LIKE ? OR h.name LIKE ?)`;
        params.push(`%${city}%`, `%${city}%`, `%${city}%`);
      }
    }

    // Star filter
    if (star) {
      query += ` AND h.star >= ?`;
      params.push(parseInt(star, 10));
    }

    // Capacity filter
    if (guestCount > 1) {
      query += ` AND rt.capacity >= ?`;
      params.push(guestCount);
    }

    query += ` GROUP BY h.id`;

    // Sorting
    if (sortBy === 'price_asc') {
      query += ` ORDER BY start_price ASC`;
    } else if (sortBy === 'price_desc') {
      query += ` ORDER BY start_price DESC`;
    } else if (sortBy === 'rating_desc') {
      query += ` ORDER BY h.rating DESC`;
    } else if (sortBy === 'star_desc') {
      query += ` ORDER BY h.star DESC`;
    } else {
      query += ` ORDER BY h.rating DESC, start_price ASC`;
    }

    query += ` LIMIT 100`;

    const [rows] = await db.query(query, params);

    // Format facilities
    const formatted = rows.map(r => {
      let facilities = [];
      try {
        facilities = typeof r.facilities === 'string' ? JSON.parse(r.facilities) : r.facilities;
      } catch (e) {
        facilities = [];
      }
      return {
        ...r,
        facilities
      };
    });

    return res.json({
      success: true,
      count: formatted.length,
      data: formatted
    });
  } catch (err) {
    console.error('Search hotels error:', err);
    return res.status(500).json({ success: false, message: 'Gagal mencari hotel.' });
  }
};

const getHotelById = async (req, res) => {
  try {
    const { id } = req.params;
    const { checkin, checkout } = req.query;
    const userId = req.user ? req.user.id : null;

    // Get hotel basic info
    const [hotelRows] = await db.query(
      `SELECT h.*, c.name AS city_name, c.country
       FROM hotels h
       JOIN cities c ON h.city_id = c.id
       WHERE h.id = ?`,
      [id]
    );

    if (hotelRows.length === 0) {
      return res.status(404).json({ success: false, message: 'Hotel tidak ditemukan.' });
    }

    const hotel = hotelRows[0];
    try {
      hotel.facilities = typeof hotel.facilities === 'string' ? JSON.parse(hotel.facilities) : hotel.facilities;
    } catch (e) {
      hotel.facilities = [];
    }

    // Check wishlist
    hotel.is_wishlist = false;
    if (userId) {
      const [w] = await db.query('SELECT 1 FROM wishlists WHERE user_id = ? AND hotel_id = ?', [userId, id]);
      hotel.is_wishlist = w.length > 0;
    }

    // Get Room Types with availability calculation
    let roomQuery = `
      SELECT rt.id, rt.hotel_id, rt.name, rt.price_per_night, rt.capacity, rt.total_rooms,
        rt.total_rooms - COALESCE(SUM(hb.rooms), 0) AS available_rooms
      FROM room_types rt
    `;
    const roomParams = [];

    if (checkin && checkout) {
      roomQuery += `
        LEFT JOIN hotel_bookings hb ON hb.room_type_id = rt.id
          AND hb.check_in < ? AND hb.check_out > ?
        LEFT JOIN bookings b ON b.id = hb.booking_id AND b.status IN ('PENDING', 'PAID')
      `;
      roomParams.push(checkout, checkin);
    } else {
      roomQuery += `
        LEFT JOIN hotel_bookings hb ON 1=0
      `;
    }

    roomQuery += ` WHERE rt.hotel_id = ? GROUP BY rt.id`;
    roomParams.push(id);

    const [rooms] = await db.query(roomQuery, roomParams);
    hotel.rooms = rooms.map(r => ({
      ...r,
      available_rooms: Math.max(0, parseInt(r.available_rooms !== null ? r.available_rooms : r.total_rooms, 10))
    }));

    // Get Reviews
    const [reviews] = await db.query(
      `SELECT r.id, r.rating, r.comment, r.created_at, u.name AS user_name
       FROM reviews r
       JOIN users u ON r.user_id = u.id
       WHERE r.hotel_id = ?
       ORDER BY r.created_at DESC LIMIT 20`,
      [id]
    );
    hotel.reviews = reviews;

    return res.json({ success: true, data: hotel });
  } catch (err) {
    console.error('Get hotel detail error:', err);
    return res.status(500).json({ success: false, message: 'Gagal mengambil detail hotel.' });
  }
};

module.exports = { searchHotels, getHotelById };

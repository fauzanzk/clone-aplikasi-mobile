const db = require('../config/db');

// GET /stations - Get all train stations
const getStations = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT s.id, s.code, s.name, s.type, c.id AS city_id, c.name AS city_name, c.country
      FROM stations s
      JOIN cities c ON c.id = s.city_id
      ORDER BY s.type DESC, s.name ASC
    `);
    return res.json({ success: true, count: rows.length, data: rows });
  } catch (err) {
    console.error('Get stations error:', err);
    return res.status(500).json({ success: false, message: 'Gagal mengambil data stasiun kereta.' });
  }
};

// GET /trains - Search trains
const searchTrains = async (req, res) => {
  try {
    const { origin_id, destination_id, date, class_type, sort_by } = req.query;

    let query = `
      SELECT 
        t.id, t.train_name, t.train_no, t.class_type,
        t.depart_at, t.arrive_at, t.price, t.seats_available,
        TIMESTAMPDIFF(MINUTE, t.depart_at, t.arrive_at) AS duration_minutes,
        so.id AS origin_id, so.code AS origin_code, so.name AS origin_name, so.type AS origin_type,
        co.name AS origin_city,
        sd.id AS dest_id, sd.code AS dest_code, sd.name AS dest_name, sd.type AS dest_type,
        cd.name AS dest_city
      FROM trains t
      JOIN stations so ON so.id = t.origin_id
      JOIN cities co ON co.id = so.city_id
      JOIN stations sd ON sd.id = t.destination_id
      JOIN cities cd ON cd.id = sd.city_id
      WHERE t.seats_available > 0
    `;
    const params = [];

    if (origin_id) {
      query += ' AND t.origin_id = ?';
      params.push(origin_id);
    }

    if (destination_id) {
      query += ' AND t.destination_id = ?';
      params.push(destination_id);
    }

    if (date) {
      query += ' AND DATE(t.depart_at) = ?';
      params.push(date);
    } else {
      query += ' AND t.depart_at >= NOW()';
    }

    if (class_type && class_type !== 'Semua') {
      query += ' AND t.class_type LIKE ?';
      params.push(`%${class_type}%`);
    }

    // Sorting
    switch (sort_by) {
      case 'price_asc':
        query += ' ORDER BY t.price ASC';
        break;
      case 'price_desc':
        query += ' ORDER BY t.price DESC';
        break;
      case 'depart_asc':
        query += ' ORDER BY t.depart_at ASC';
        break;
      case 'duration_asc':
        query += ' ORDER BY duration_minutes ASC';
        break;
      default:
        query += ' ORDER BY t.depart_at ASC';
    }

    const [rows] = await db.query(query, params);
    return res.json({ success: true, count: rows.length, data: rows });
  } catch (err) {
    console.error('Search trains error:', err);
    return res.status(500).json({ success: false, message: 'Gagal mencari jadwal kereta api.' });
  }
};

// GET /trains/:id - Get single train details
const getTrainById = async (req, res) => {
  try {
    const { id } = req.params;
    const [rows] = await db.query(
      `SELECT 
        t.id, t.train_name, t.train_no, t.class_type,
        t.depart_at, t.arrive_at, t.price, t.seats_available,
        TIMESTAMPDIFF(MINUTE, t.depart_at, t.arrive_at) AS duration_minutes,
        so.id AS origin_id, so.code AS origin_code, so.name AS origin_name, so.type AS origin_type,
        co.name AS origin_city,
        sd.id AS dest_id, sd.code AS dest_code, sd.name AS dest_name, sd.type AS dest_type,
        cd.name AS dest_city
      FROM trains t
      JOIN stations so ON so.id = t.origin_id
      JOIN cities co ON co.id = so.city_id
      JOIN stations sd ON sd.id = t.destination_id
      JOIN cities cd ON cd.id = sd.city_id
      WHERE t.id = ?`,
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Jadwal kereta tidak ditemukan.' });
    }

    return res.json({ success: true, data: rows[0] });
  } catch (err) {
    console.error('Get train detail error:', err);
    return res.status(500).json({ success: false, message: 'Gagal mengambil detail kereta api.' });
  }
};

module.exports = {
  getStations,
  searchTrains,
  getTrainById
};

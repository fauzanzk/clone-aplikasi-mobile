const db = require('../config/db');

// GET /stations - Get all train stations
const getStations = async (req, res) => {
  try {
    const search = req.query.search;
    let query = `
      SELECT s.id, s.code, s.name, s.type, c.id AS city_id, c.name AS city_name, c.country
      FROM stations s
      JOIN cities c ON c.id = s.city_id
    `;
    const params = [];
    if (search) {
      query += ` WHERE s.name LIKE ? OR s.code LIKE ? OR c.name LIKE ?`;
      params.push(`%${search}%`, `%${search}%`, `%${search}%`);
    }
    query += ` ORDER BY s.type DESC, s.name ASC`;
    const [rows] = await db.query(query, params);
    return res.json({ success: true, count: rows.length, data: rows });
  } catch (err) {
    console.error('Get stations error:', err);
    return res.status(500).json({ success: false, message: 'Gagal mengambil data stasiun kereta.' });
  }
};

// GET /trains - Search trains
const searchTrains = async (req, res) => {
  try {
    const origin = req.query.from || req.query.origin_id;
    const dest = req.query.to || req.query.destination_id;
    const pax = parseInt(req.query.pax || '1', 10);
    const date = req.query.date;
    const classType = req.query.class || req.query.class_type;
    const sortBy = req.query.sortBy || req.query.sort_by;

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
      WHERE t.seats_available >= ?
    `;
    const params = [pax];

    // Filter Origin (ID, station code, station name, or city name)
    if (origin) {
      if (!isNaN(origin)) {
        query += ' AND (t.origin_id = ? OR so.city_id = ?)';
        params.push(parseInt(origin, 10), parseInt(origin, 10));
      } else {
        query += ' AND (so.code = ? OR LOWER(so.name) LIKE ? OR LOWER(co.name) LIKE ?)';
        params.push(origin.toUpperCase(), `%${origin.toLowerCase()}%`, `%${origin.toLowerCase()}%`);
      }
    }

    // Filter Destination (ID, station code, station name, or city name)
    if (dest) {
      if (!isNaN(dest)) {
        query += ' AND (t.destination_id = ? OR sd.city_id = ?)';
        params.push(parseInt(dest, 10), parseInt(dest, 10));
      } else {
        query += ' AND (sd.code = ? OR LOWER(sd.name) LIKE ? OR LOWER(cd.name) LIKE ?)';
        params.push(dest.toUpperCase(), `%${dest.toLowerCase()}%`, `%${dest.toLowerCase()}%`);
      }
    }

    // Date filter
    if (date) {
      query += ' AND DATE(t.depart_at) = ?';
      params.push(date);
    } else {
      query += ' AND t.depart_at >= NOW()';
    }

    // Class filter
    if (classType && classType !== 'Semua' && classType !== 'Semua Kelas') {
      query += ' AND t.class_type LIKE ?';
      params.push(`%${classType}%`);
    }

    // Sorting
    switch (sortBy) {
      case 'price_asc':
        query += ' ORDER BY t.price ASC';
        break;
      case 'price_desc':
        query += ' ORDER BY t.price DESC';
        break;
      case 'time_asc':
      case 'depart_asc':
        query += ' ORDER BY t.depart_at ASC';
        break;
      case 'time_desc':
      case 'depart_desc':
        query += ' ORDER BY t.depart_at DESC';
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

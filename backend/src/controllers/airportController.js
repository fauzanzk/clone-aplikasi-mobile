const db = require('../config/db');

const getAirports = async (req, res) => {
  try {
    const { search } = req.query;
    let query = `
      SELECT a.id, a.code, a.name, a.city_id, c.name as city_name, c.country
      FROM airports a
      JOIN cities c ON a.city_id = c.id
    `;
    const params = [];

    if (search) {
      query += ` WHERE a.code LIKE ? OR a.name LIKE ? OR c.name LIKE ?`;
      const s = `%${search}%`;
      params.push(s, s, s);
    }

    query += ` ORDER BY c.name ASC`;
    const [rows] = await db.query(query, params);
    return res.json({ success: true, data: rows });
  } catch (err) {
    console.error('Get airports error:', err);
    return res.status(500).json({ success: false, message: 'Gagal mengambil data bandara.' });
  }
};

const getCities = async (req, res) => {
  try {
    const { search } = req.query;
    let query = 'SELECT id, name, country FROM cities';
    const params = [];

    if (search) {
      query += ' WHERE name LIKE ?';
      params.push(`%${search}%`);
    }

    query += ' ORDER BY name ASC';
    const [rows] = await db.query(query, params);
    return res.json({ success: true, data: rows });
  } catch (err) {
    console.error('Get cities error:', err);
    return res.status(500).json({ success: false, message: 'Gagal mengambil data kota.' });
  }
};

module.exports = { getAirports, getCities };

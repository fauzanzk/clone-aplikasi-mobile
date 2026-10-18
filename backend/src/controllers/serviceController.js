const db = require('../config/db');

// GET /services/buses
const getBuses = async (req, res) => {
  try {
    const { origin, dest } = req.query;
    let query = 'SELECT * FROM buses WHERE 1=1';
    const params = [];

    if (origin) {
      query += ' AND origin_city LIKE ?';
      params.push(`%${origin}%`);
    }
    if (dest) {
      query += ' AND dest_city LIKE ?';
      params.push(`%${dest}%`);
    }
    query += ' ORDER BY price ASC';

    const [rows] = await db.query(query, params);
    return res.json({ success: true, count: rows.length, data: rows });
  } catch (err) {
    console.error('Get buses error:', err);
    return res.status(500).json({ success: false, message: 'Gagal mengambil data bus & travel.' });
  }
};

// GET /services/attractions
const getAttractions = async (req, res) => {
  try {
    const { city_id, category } = req.query;
    let query = `
      SELECT a.*, c.name AS city_name
      FROM attractions a
      JOIN cities c ON c.id = a.city_id
      WHERE 1=1
    `;
    const params = [];

    if (city_id) {
      query += ' AND a.city_id = ?';
      params.push(city_id);
    }
    if (category) {
      query += ' AND a.category LIKE ?';
      params.push(`%${category}%`);
    }
    query += ' ORDER BY a.rating DESC';

    const [rows] = await db.query(query, params);
    return res.json({ success: true, count: rows.length, data: rows });
  } catch (err) {
    console.error('Get attractions error:', err);
    return res.status(500).json({ success: false, message: 'Gagal mengambil data Xperience & wahana.' });
  }
};

// GET /services/cars
const getCars = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM car_rentals ORDER BY price_per_day ASC');
    return res.json({ success: true, count: rows.length, data: rows });
  } catch (err) {
    console.error('Get cars error:', err);
    return res.status(500).json({ success: false, message: 'Gagal mengambil data sewa mobil.' });
  }
};

// GET /services/insurances
const getInsurances = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM insurances ORDER BY price ASC');
    const formatted = rows.map(r => ({
      ...r,
      benefits: typeof r.benefits === 'string' ? JSON.parse(r.benefits) : r.benefits
    }));
    return res.json({ success: true, count: formatted.length, data: formatted });
  } catch (err) {
    console.error('Get insurances error:', err);
    return res.status(500).json({ success: false, message: 'Gagal mengambil data asuransi perjalanan.' });
  }
};

module.exports = {
  getBuses,
  getAttractions,
  getCars,
  getInsurances
};

const db = require('../config/db');

const searchFlights = async (req, res) => {
  try {
    const { from, to, date, pax, airline, sortBy } = req.query;
    const passengersCount = parseInt(pax || '1', 10);

    let query = `
      SELECT 
        f.id, f.airline, f.flight_no, f.origin_id, f.destination_id,
        f.depart_at, f.arrive_at, f.price, f.seats_available,
        o.code AS origin_code, o.name AS origin_name, oc.name AS origin_city,
        d.code AS dest_code, d.name AS dest_name, dc.name AS dest_city,
        TIMESTAMPDIFF(MINUTE, f.depart_at, f.arrive_at) AS duration_minutes
      FROM flights f
      JOIN airports o ON o.id = f.origin_id
      JOIN cities oc ON oc.id = o.city_id
      JOIN airports d ON d.id = f.destination_id
      JOIN cities dc ON dc.id = d.city_id
      WHERE f.seats_available >= ?
    `;
    const params = [passengersCount];

    // Origin filter (ID or Code)
    if (from) {
      if (!isNaN(from)) {
        query += ` AND f.origin_id = ?`;
        params.push(parseInt(from, 10));
      } else {
        query += ` AND (o.code = ? OR oc.name LIKE ?)`;
        params.push(from.toUpperCase(), `%${from}%`);
      }
    }

    // Destination filter (ID or Code)
    if (to) {
      if (!isNaN(to)) {
        query += ` AND f.destination_id = ?`;
        params.push(parseInt(to, 10));
      } else {
        query += ` AND (d.code = ? OR dc.name LIKE ?)`;
        params.push(to.toUpperCase(), `%${to}%`);
      }
    }

    // Date filter
    if (date) {
      query += ` AND DATE(f.depart_at) = ?`;
      params.push(date);
    } else {
      query += ` AND f.depart_at >= NOW()`;
    }

    // Airline filter
    if (airline) {
      query += ` AND f.airline = ?`;
      params.push(airline);
    }

    // Sorting
    if (sortBy === 'price_desc') {
      query += ` ORDER BY f.price DESC`;
    } else if (sortBy === 'time_asc') {
      query += ` ORDER BY f.depart_at ASC`;
    } else if (sortBy === 'time_desc') {
      query += ` ORDER BY f.depart_at DESC`;
    } else if (sortBy === 'duration_asc') {
      query += ` ORDER BY duration_minutes ASC`;
    } else {
      query += ` ORDER BY f.price ASC`; // default cheapest
    }

    query += ` LIMIT 100`;

    const [rows] = await db.query(query, params);
    return res.json({
      success: true,
      count: rows.length,
      data: rows
    });
  } catch (err) {
    console.error('Search flights error:', err);
    return res.status(500).json({ success: false, message: 'Gagal mencari penerbangan.' });
  }
};

const getFlightById = async (req, res) => {
  try {
    const { id } = req.params;
    const [rows] = await db.query(
      `SELECT 
        f.id, f.airline, f.flight_no, f.origin_id, f.destination_id,
        f.depart_at, f.arrive_at, f.price, f.seats_available,
        o.code AS origin_code, o.name AS origin_name, oc.name AS origin_city,
        d.code AS dest_code, d.name AS dest_name, dc.name AS dest_city,
        TIMESTAMPDIFF(MINUTE, f.depart_at, f.arrive_at) AS duration_minutes
      FROM flights f
      JOIN airports o ON o.id = f.origin_id
      JOIN cities oc ON oc.id = o.city_id
      JOIN airports d ON d.id = f.destination_id
      JOIN cities dc ON dc.id = d.city_id
      WHERE f.id = ?`,
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Penerbangan tidak ditemukan.' });
    }

    return res.json({ success: true, data: rows[0] });
  } catch (err) {
    console.error('Get flight by id error:', err);
    return res.status(500).json({ success: false, message: 'Gagal mengambil detail penerbangan.' });
  }
};

module.exports = { searchFlights, getFlightById };

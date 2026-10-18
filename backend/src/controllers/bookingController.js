const db = require('../config/db');

// Helper to generate unique booking code: 8-10 chars (e.g. TL8K2M9QX)
const generateBookingCode = () => {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let result = 'TL';
  for (let i = 0; i < 7; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
};

// Check and mark expired bookings, restoring flight and train seats
const checkAndExpireBookings = async () => {
  try {
    const [expiredList] = await db.query(
      `SELECT b.id, b.type, fb.flight_id, fb.seats AS flight_seats, tb.train_id, tb.seats AS train_seats, bb.bus_id
       FROM bookings b
       LEFT JOIN flight_bookings fb ON fb.booking_id = b.id
       LEFT JOIN train_bookings tb ON tb.booking_id = b.id
       LEFT JOIN bus_bookings bb ON bb.booking_id = b.id
       WHERE b.status = 'PENDING' AND b.expires_at < NOW()`
    );

    for (const exp of expiredList) {
      await db.query(`UPDATE bookings SET status = 'EXPIRED' WHERE id = ?`, [exp.id]);
      if (exp.type === 'FLIGHT' && exp.flight_id && exp.flight_seats) {
        await db.query(`UPDATE flights SET seats_available = seats_available + ? WHERE id = ?`, [
          exp.flight_seats,
          exp.flight_id
        ]);
      } else if (exp.type === 'TRAIN' && exp.train_id && exp.train_seats) {
        await db.query(`UPDATE trains SET seats_available = seats_available + ? WHERE id = ?`, [
          exp.train_seats,
          exp.train_id
        ]);
      } else if (exp.type === 'BUS' && exp.bus_id) {
        await db.query(`UPDATE buses SET seats_available = seats_available + 1 WHERE id = ?`, [
          exp.bus_id
        ]);
      }
    }
  } catch (err) {
    console.error('Error expiring bookings:', err.message);
  }
};

const createFlightBooking = async (req, res) => {
  const connection = await db.getConnection();
  try {
    const userId = req.user.id;
    const { flight_id, seats = 1, passengers } = req.body;

    if (!flight_id || !passengers || !Array.isArray(passengers) || passengers.length === 0) {
      return res.status(400).json({ success: false, message: 'Data penerbangan dan penumpang tidak lengkap.' });
    }

    const seatsCount = parseInt(seats || passengers.length, 10);

    await connection.beginTransaction();

    // 1. Lock flight row and check seat availability
    const [flightRows] = await connection.query(
      'SELECT id, price, seats_available FROM flights WHERE id = ? FOR UPDATE',
      [flight_id]
    );

    if (flightRows.length === 0) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Penerbangan tidak ditemukan.' });
    }

    const flight = flightRows[0];
    if (flight.seats_available < seatsCount) {
      await connection.rollback();
      return res.status(400).json({
        success: false,
        message: `Kursi tidak mencukupi. Tersedia hanya ${flight.seats_available} kursi.`
      });
    }

    // 2. Decrement seats
    await connection.query('UPDATE flights SET seats_available = seats_available - ? WHERE id = ?', [
      seatsCount,
      flight_id
    ]);

    // 3. Create booking row
    const bookingCode = generateBookingCode();
    const totalPrice = flight.price * seatsCount;

    const [bookingResult] = await connection.query(
      `INSERT INTO bookings (code, user_id, type, total_price, status, expires_at)
       VALUES (?, ?, 'FLIGHT', ?, 'PENDING', DATE_ADD(NOW(), INTERVAL 1 HOUR))`,
      [bookingCode, userId, totalPrice]
    );

    const bookingId = bookingResult.insertId;

    // 4. Create flight_bookings row
    await connection.query(
      'INSERT INTO flight_bookings (booking_id, flight_id, seats) VALUES (?, ?, ?)',
      [bookingId, flight_id, seatsCount]
    );

    // 5. Create passengers
    for (const p of passengers) {
      await connection.query(
        'INSERT INTO passengers (booking_id, title, full_name, id_number) VALUES (?, ?, ?, ?)',
        [bookingId, p.title || 'Tn', p.full_name, p.id_number || '']
      );
    }

    await connection.commit();

    return res.status(201).json({
      success: true,
      message: 'Pesanan tiket pesawat berhasil dibuat.',
      data: {
        booking_id: bookingId,
        code: bookingCode,
        total_price: totalPrice,
        status: 'PENDING',
        expires_at: new Date(Date.now() + 60 * 60 * 1000).toISOString()
      }
    });
  } catch (err) {
    await connection.rollback();
    console.error('Create flight booking error:', err);
    return res.status(500).json({ success: false, message: 'Gagal membuat pesanan penerbangan.' });
  } finally {
    connection.release();
  }
};

const createHotelBooking = async (req, res) => {
  const connection = await db.getConnection();
  try {
    const userId = req.user.id;
    const { room_type_id, check_in, check_out, rooms = 1, guests = 1, guest_name } = req.body;

    if (!room_type_id || !check_in || !check_out || !guest_name) {
      return res.status(400).json({ success: false, message: 'Semua kolom pemesanan hotel wajib diisi.' });
    }

    const roomsCount = parseInt(rooms, 10);
    const guestsCount = parseInt(guests, 10);

    const checkInDate = new Date(check_in);
    const checkOutDate = new Date(check_out);
    const timeDiff = checkOutDate.getTime() - checkInDate.getTime();
    const nights = Math.max(1, Math.ceil(timeDiff / (1000 * 3600 * 24)));

    await connection.beginTransaction();

    // 1. Check room availability with FOR UPDATE
    const [availabilityRows] = await connection.query(
      `SELECT rt.id, rt.price_per_night, rt.total_rooms,
              rt.total_rooms - COALESCE(SUM(hb.rooms), 0) AS available
       FROM room_types rt
       LEFT JOIN hotel_bookings hb ON hb.room_type_id = rt.id
         AND hb.check_in < ? AND hb.check_out > ?
       LEFT JOIN bookings b ON b.id = hb.booking_id AND b.status IN ('PENDING', 'PAID')
       WHERE rt.id = ?
       GROUP BY rt.id FOR UPDATE`,
      [check_out, check_in, room_type_id]
    );

    if (availabilityRows.length === 0) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Tipe kamar tidak ditemukan.' });
    }

    const roomType = availabilityRows[0];
    const availableRooms = parseInt(roomType.available !== null ? roomType.available : roomType.total_rooms, 10);

    if (availableRooms < roomsCount) {
      await connection.rollback();
      return res.status(400).json({
        success: false,
        message: `Kamar tidak mencukupi untuk tanggal yang dipilih. Tersisa ${availableRooms} kamar.`
      });
    }

    // 2. Create booking
    const bookingCode = generateBookingCode();
    const totalPrice = roomType.price_per_night * nights * roomsCount;

    const [bookingResult] = await connection.query(
      `INSERT INTO bookings (code, user_id, type, total_price, status, expires_at)
       VALUES (?, ?, 'HOTEL', ?, 'PENDING', DATE_ADD(NOW(), INTERVAL 1 HOUR))`,
      [bookingCode, userId, totalPrice]
    );

    const bookingId = bookingResult.insertId;

    // 3. Create hotel_bookings row
    await connection.query(
      `INSERT INTO hotel_bookings (booking_id, room_type_id, check_in, check_out, rooms, guests, guest_name)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [bookingId, room_type_id, check_in, check_out, roomsCount, guestsCount, guest_name]
    );

    await connection.commit();

    return res.status(201).json({
      success: true,
      message: 'Pesanan kamar hotel berhasil dibuat.',
      data: {
        booking_id: bookingId,
        code: bookingCode,
        total_price: totalPrice,
        nights,
        status: 'PENDING',
        expires_at: new Date(Date.now() + 60 * 60 * 1000).toISOString()
      }
    });
  } catch (err) {
    await connection.rollback();
    console.error('Create hotel booking error:', err);
    return res.status(500).json({ success: false, message: 'Gagal membuat pesanan hotel.' });
  } finally {
    connection.release();
  }
};

const createTrainBooking = async (req, res) => {
  const connection = await db.getConnection();
  try {
    const userId = req.user.id;
    const { train_id, seats = 1, passengers } = req.body;

    if (!train_id || !passengers || !Array.isArray(passengers) || passengers.length === 0) {
      return res.status(400).json({ success: false, message: 'Data kereta dan penumpang tidak lengkap.' });
    }

    const seatsCount = parseInt(seats || passengers.length, 10);

    await connection.beginTransaction();

    // 1. Lock train row and check seat availability
    const [trainRows] = await connection.query(
      'SELECT id, price, seats_available FROM trains WHERE id = ? FOR UPDATE',
      [train_id]
    );

    if (trainRows.length === 0) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Jadwal kereta tidak ditemukan.' });
    }

    const train = trainRows[0];
    if (train.seats_available < seatsCount) {
      await connection.rollback();
      return res.status(400).json({
        success: false,
        message: `Kursi tidak mencukupi. Tersedia hanya ${train.seats_available} kursi.`
      });
    }

    // 2. Decrement seats
    await connection.query('UPDATE trains SET seats_available = seats_available - ? WHERE id = ?', [
      seatsCount,
      train_id
    ]);

    // 3. Create booking row
    const bookingCode = generateBookingCode();
    const totalPrice = train.price * seatsCount;

    const [bookingResult] = await connection.query(
      `INSERT INTO bookings (code, user_id, type, total_price, status, expires_at)
       VALUES (?, ?, 'TRAIN', ?, 'PENDING', DATE_ADD(NOW(), INTERVAL 1 HOUR))`,
      [bookingCode, userId, totalPrice]
    );

    const bookingId = bookingResult.insertId;

    // 4. Create train_bookings row
    await connection.query(
      'INSERT INTO train_bookings (booking_id, train_id, seats) VALUES (?, ?, ?)',
      [bookingId, train_id, seatsCount]
    );

    // 5. Create passengers
    for (const p of passengers) {
      await connection.query(
        'INSERT INTO passengers (booking_id, title, full_name, id_number) VALUES (?, ?, ?, ?)',
        [bookingId, p.title || 'Tn', p.full_name, p.id_number || '']
      );
    }

    await connection.commit();

    return res.status(201).json({
      success: true,
      message: 'Pesanan tiket kereta api berhasil dibuat.',
      data: {
        booking_id: bookingId,
        code: bookingCode,
        total_price: totalPrice,
        status: 'PENDING',
        expires_at: new Date(Date.now() + 60 * 60 * 1000).toISOString()
      }
    });
  } catch (err) {
    await connection.rollback();
    console.error('Create train booking error:', err);
    return res.status(500).json({ success: false, message: 'Gagal membuat pesanan kereta api.' });
  } finally {
    connection.release();
  }
};

const createBusBooking = async (req, res) => {
  const connection = await db.getConnection();
  try {
    const userId = req.user.id;
    const { bus_id, seat_no = 1, passenger_name } = req.body;

    if (!bus_id) {
      return res.status(400).json({ success: false, message: 'ID armada bus wajib disertakan.' });
    }

    await connection.beginTransaction();

    // 1. Lock bus row and check seats
    const [busRows] = await connection.query(
      'SELECT id, operator_name, bus_class, origin_city, dest_city, price, seats_available FROM buses WHERE id = ? FOR UPDATE',
      [bus_id]
    );

    if (busRows.length === 0) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Jadwal bus tidak ditemukan.' });
    }

    const bus = busRows[0];
    if (bus.seats_available < 1) {
      await connection.rollback();
      return res.status(400).json({ success: false, message: 'Maaf, semua kursi bus ini sudah penuh.' });
    }

    // 2. Decrement seat
    await connection.query('UPDATE buses SET seats_available = seats_available - 1 WHERE id = ?', [bus_id]);

    // 3. Create booking
    const bookingCode = generateBookingCode();
    const totalPrice = bus.price;
    const [bookingResult] = await connection.query(
      `INSERT INTO bookings (code, user_id, type, total_price, status, expires_at)
       VALUES (?, ?, 'BUS', ?, 'PENDING', DATE_ADD(NOW(), INTERVAL 1 HOUR))`,
      [bookingCode, userId, totalPrice]
    );

    const bookingId = bookingResult.insertId;

    // 4. Create bus_bookings row
    await connection.query(
      'INSERT INTO bus_bookings (booking_id, bus_id, seat_no, passenger_name) VALUES (?, ?, ?, ?)',
      [bookingId, bus_id, seat_no, passenger_name || req.user.name || 'Penumpang Bus']
    );

    await connection.commit();

    return res.status(201).json({
      success: true,
      message: 'Pesanan tiket bus berhasil dibuat.',
      data: {
        booking_id: bookingId,
        code: bookingCode,
        total_price: totalPrice,
        status: 'PENDING',
        expires_at: new Date(Date.now() + 60 * 60 * 1000).toISOString()
      }
    });
  } catch (err) {
    await connection.rollback();
    console.error('Create bus booking error:', err);
    return res.status(500).json({ success: false, message: 'Gagal membuat pesanan bus.' });
  } finally {
    connection.release();
  }
};

const payBooking = async (req, res) => {
  try {
    const { id } = req.params;
    const { payment_method = 'BCA Virtual Account' } = req.body;
    const userId = req.user.id;

    // Check booking exists and belongs to user
    const [rows] = await db.query('SELECT * FROM bookings WHERE id = ? AND user_id = ?', [id, userId]);
    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Pesanan tidak ditemukan.' });
    }

    const booking = rows[0];

    if (booking.status === 'PAID') {
      return res.status(400).json({ success: false, message: 'Pesanan ini sudah berhasil dibayar sebelumnya.' });
    }

    if (booking.status === 'CANCELLED') {
      return res.status(400).json({ success: false, message: 'Pesanan ini sudah dibatalkan.' });
    }

    if (booking.status === 'EXPIRED' || (booking.expires_at && new Date(booking.expires_at) < new Date())) {
      await db.query("UPDATE bookings SET status = 'EXPIRED' WHERE id = ?", [id]);
      return res.status(400).json({ success: false, message: 'Batas waktu pembayaran pesanan ini telah habis (Expired).' });
    }

    // Process payment simulation
    await db.query(
      "UPDATE bookings SET status = 'PAID', paid_at = NOW(), payment_method = ? WHERE id = ?",
      [payment_method, id]
    );

    const [updated] = await db.query('SELECT * FROM bookings WHERE id = ?', [id]);

    return res.json({
      success: true,
      message: 'Pembayaran simulasi berhasil! Status pesanan kini PAID.',
      data: updated[0]
    });
  } catch (err) {
    console.error('Pay booking error:', err);
    return res.status(500).json({ success: false, message: 'Gagal memproses pembayaran.' });
  }
};

const cancelBooking = async (req, res) => {
  const connection = await db.getConnection();
  try {
    const { id } = req.params;
    const userId = req.user.id;

    await connection.beginTransaction();

    const [rows] = await connection.query(
      `SELECT b.*, fb.flight_id, fb.seats AS flight_seats, tb.train_id, tb.seats AS train_seats, bb.bus_id
       FROM bookings b
       LEFT JOIN flight_bookings fb ON fb.booking_id = b.id
       LEFT JOIN train_bookings tb ON tb.booking_id = b.id
       LEFT JOIN bus_bookings bb ON bb.booking_id = b.id
       WHERE b.id = ? AND b.user_id = ? FOR UPDATE`,
      [id, userId]
    );

    if (rows.length === 0) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Pesanan tidak ditemukan.' });
    }

    const booking = rows[0];
    if (booking.status === 'CANCELLED') {
      await connection.rollback();
      return res.status(400).json({ success: false, message: 'Pesanan sudah dibatalkan.' });
    }

    // Cancel booking
    await connection.query("UPDATE bookings SET status = 'CANCELLED' WHERE id = ?", [id]);

    // Restore seats if it was flight, train or bus booking
    if (booking.type === 'FLIGHT' && booking.flight_id && booking.flight_seats) {
      await connection.query('UPDATE flights SET seats_available = seats_available + ? WHERE id = ?', [
        booking.flight_seats,
        booking.flight_id
      ]);
    } else if (booking.type === 'TRAIN' && booking.train_id && booking.train_seats) {
      await connection.query('UPDATE trains SET seats_available = seats_available + ? WHERE id = ?', [
        booking.train_seats,
        booking.train_id
      ]);
    } else if (booking.type === 'BUS' && booking.bus_id) {
      await connection.query('UPDATE buses SET seats_available = seats_available + 1 WHERE id = ?', [
        booking.bus_id
      ]);
    }

    await connection.commit();

    return res.json({
      success: true,
      message: 'Pesanan berhasil dibatalkan.',
      data: { id: booking.id, status: 'CANCELLED' }
    });
  } catch (err) {
    await connection.rollback();
    console.error('Cancel booking error:', err);
    return res.status(500).json({ success: false, message: 'Gagal membatalkan pesanan.' });
  } finally {
    connection.release();
  }
};

const getUserBookings = async (req, res) => {
  try {
    const userId = req.user.id;
    const { status } = req.query;

    // Check expiration before returning
    await checkAndExpireBookings();

    let query = `
      SELECT 
        b.id, b.code, b.type, b.total_price, b.status, b.payment_method,
        b.paid_at, b.expires_at, b.created_at,
        -- Flight, Train or Bus details
        COALESCE(f.airline, t.train_name, bs.operator_name) AS airline,
        COALESCE(f.flight_no, t.train_no, bs.bus_class) AS flight_no,
        COALESCE(f.depart_at, t.depart_at, CONCAT(CURDATE(), ' ', bs.departure_time, ':00')) AS depart_at,
        COALESCE(f.arrive_at, t.arrive_at, CONCAT(CURDATE(), ' ', bs.arrival_time, ':00')) AS arrive_at,
        COALESCE(o.code, so.code, bs.origin_city) AS origin_code,
        COALESCE(o.name, so.name, bs.origin_city) AS origin_name,
        COALESCE(oc.name, soc.name, bs.origin_city) AS origin_city,
        COALESCE(d.code, sd.code, bs.dest_city) AS dest_code,
        COALESCE(d.name, sd.name, bs.dest_city) AS dest_name,
        COALESCE(dc.name, sdc.name, bs.dest_city) AS dest_city,
        COALESCE(fb.seats, tb.seats, 1) AS flight_seats,
        COALESCE(t.class_type, bs.bus_class) AS train_class,
        bb.seat_no AS bus_seat_no,
        -- Hotel details if hotel
        h.id AS hotel_id, h.name AS hotel_name, h.image_url AS hotel_image, h.star AS hotel_star,
        hc.name AS hotel_city,
        rt.name AS room_name,
        hb.check_in, hb.check_out, hb.rooms AS hotel_rooms, hb.guests AS hotel_guests, hb.guest_name
      FROM bookings b
      LEFT JOIN flight_bookings fb ON fb.booking_id = b.id
      LEFT JOIN flights f ON f.id = fb.flight_id
      LEFT JOIN airports o ON o.id = f.origin_id
      LEFT JOIN cities oc ON oc.id = o.city_id
      LEFT JOIN airports d ON d.id = f.destination_id
      LEFT JOIN cities dc ON dc.id = d.city_id
      LEFT JOIN train_bookings tb ON tb.booking_id = b.id
      LEFT JOIN trains t ON t.id = tb.train_id
      LEFT JOIN stations so ON so.id = t.origin_id
      LEFT JOIN cities soc ON soc.id = so.city_id
      LEFT JOIN stations sd ON sd.id = t.destination_id
      LEFT JOIN cities sdc ON sdc.id = sd.city_id
      LEFT JOIN bus_bookings bb ON bb.booking_id = b.id
      LEFT JOIN buses bs ON bs.id = bb.bus_id
      LEFT JOIN hotel_bookings hb ON hb.booking_id = b.id
      LEFT JOIN room_types rt ON rt.id = hb.room_type_id
      LEFT JOIN hotels h ON h.id = rt.hotel_id
      LEFT JOIN cities hc ON hc.id = h.city_id
      WHERE b.user_id = ?
    `;
    const params = [userId];

    if (status && status !== 'ALL') {
      query += ' AND b.status = ?';
      params.push(status);
    }

    query += ' ORDER BY b.created_at DESC';

    const [rows] = await db.query(query, params);
    return res.json({ success: true, count: rows.length, data: rows });
  } catch (err) {
    console.error('Get user bookings error:', err);
    return res.status(500).json({ success: false, message: 'Gagal mengambil daftar pesanan.' });
  }
};

const getBookingDetail = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    await checkAndExpireBookings();

    const [bookingRows] = await db.query(
      `SELECT 
        b.id, b.code, b.type, b.total_price, b.status, b.payment_method,
        b.paid_at, b.expires_at, b.created_at,
        -- Flight, Train or Bus details
        COALESCE(f.airline, t.train_name, bs.operator_name) AS airline,
        COALESCE(f.flight_no, t.train_no, bs.bus_class) AS flight_no,
        COALESCE(f.depart_at, t.depart_at, CONCAT(CURDATE(), ' ', bs.departure_time, ':00')) AS depart_at,
        COALESCE(f.arrive_at, t.arrive_at, CONCAT(CURDATE(), ' ', bs.arrival_time, ':00')) AS arrive_at,
        COALESCE(f.price, t.price, bs.price) AS flight_unit_price,
        COALESCE(o.code, so.code, bs.origin_city) AS origin_code,
        COALESCE(o.name, so.name, bs.origin_city) AS origin_name,
        COALESCE(oc.name, soc.name, bs.origin_city) AS origin_city,
        COALESCE(d.code, sd.code, bs.dest_city) AS dest_code,
        COALESCE(d.name, sd.name, bs.dest_city) AS dest_name,
        COALESCE(dc.name, sdc.name, bs.dest_city) AS dest_city,
        COALESCE(fb.seats, tb.seats, 1) AS flight_seats,
        COALESCE(t.class_type, bs.bus_class) AS train_class,
        bb.seat_no AS bus_seat_no,
        -- Hotel details
        h.id AS hotel_id, h.name AS hotel_name, h.image_url AS hotel_image, h.star AS hotel_star,
        h.address AS hotel_address,
        hc.name AS hotel_city,
        rt.name AS room_name, rt.price_per_night,
        hb.check_in, hb.check_out, hb.rooms AS hotel_rooms, hb.guests AS hotel_guests, hb.guest_name
      FROM bookings b
      LEFT JOIN flight_bookings fb ON fb.booking_id = b.id
      LEFT JOIN flights f ON f.id = fb.flight_id
      LEFT JOIN airports o ON o.id = f.origin_id
      LEFT JOIN cities oc ON oc.id = o.city_id
      LEFT JOIN airports d ON d.id = f.destination_id
      LEFT JOIN cities dc ON dc.id = d.city_id
      LEFT JOIN train_bookings tb ON tb.booking_id = b.id
      LEFT JOIN trains t ON t.id = tb.train_id
      LEFT JOIN stations so ON so.id = t.origin_id
      LEFT JOIN cities soc ON soc.id = so.city_id
      LEFT JOIN stations sd ON sd.id = t.destination_id
      LEFT JOIN cities sdc ON sdc.id = sd.city_id
      LEFT JOIN bus_bookings bb ON bb.booking_id = b.id
      LEFT JOIN buses bs ON bs.id = bb.bus_id
      LEFT JOIN hotel_bookings hb ON hb.booking_id = b.id
      LEFT JOIN room_types rt ON rt.id = hb.room_type_id
      LEFT JOIN hotels h ON h.id = rt.hotel_id
      LEFT JOIN cities hc ON hc.id = h.city_id
      WHERE b.id = ? AND b.user_id = ?`,
      [id, userId]
    );

    if (bookingRows.length === 0) {
      return res.status(404).json({ success: false, message: 'Pesanan tidak ditemukan.' });
    }

    const booking = bookingRows[0];

    // If flight or train, fetch passengers
    if (booking.type === 'FLIGHT' || booking.type === 'TRAIN') {
      const [passengers] = await db.query(
        'SELECT id, title, full_name, id_number FROM passengers WHERE booking_id = ?',
        [id]
      );
      booking.passengers = passengers;
    } else if (booking.type === 'BUS') {
      const [busBookingRows] = await db.query(
        'SELECT seat_no, passenger_name FROM bus_bookings WHERE booking_id = ?',
        [id]
      );
      if (busBookingRows.length > 0) {
        booking.bus_seat_no = busBookingRows[0].seat_no;
        booking.passengers = [{
          title: 'Tn',
          full_name: busBookingRows[0].passenger_name || 'Penumpang',
          id_number: 'Kursi #' + busBookingRows[0].seat_no
        }];
      }
    }

    // QR Data string for e-ticket / voucher
    booking.qr_data = JSON.stringify({
      code: booking.code,
      type: booking.type,
      status: booking.status,
      user_id: userId,
      verified_by: 'TraveLokuy Official System'
    });

    return res.json({ success: true, data: booking });
  } catch (err) {
    console.error('Get booking detail error:', err);
    return res.status(500).json({ success: false, message: 'Gagal mengambil detail pesanan.' });
  }
};

module.exports = {
  createFlightBooking,
  createHotelBooking,
  createTrainBooking,
  createBusBooking,
  payBooking,
  cancelBooking,
  getUserBookings,
  getBookingDetail
};

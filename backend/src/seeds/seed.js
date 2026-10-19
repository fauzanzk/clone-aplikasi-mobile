const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
const dotenv = require('dotenv');
const path = require('path');
const fs = require('fs');

dotenv.config({ path: path.join(__dirname, '../../.env') });

const dbConfig = {
  host: process.env.DB_HOST || '127.0.0.1',
  port: parseInt(process.env.DB_PORT || '3306', 10),
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || ''
};

async function seed() {
  console.log('Connecting to MySQL Server at', `${dbConfig.host}:${dbConfig.port}...`);
  let connection;
  try {
    connection = await mysql.createConnection(dbConfig);
  } catch (err) {
    console.error('Failed to connect to MySQL server:', err.message);
    console.error('Please make sure MySQL/XAMPP is running and password in .env is correct.');
    process.exit(1);
  }

  console.log('Creating database traveloka_clone if not exists...');
  await connection.query('CREATE DATABASE IF NOT EXISTS traveloka_clone CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;');
  await connection.query('USE traveloka_clone;');

  console.log('Executing schema.sql...');
  const schemaSql = fs.readFileSync(path.join(__dirname, '../../schema.sql'), 'utf-8');
  const statements = schemaSql
    .split(';')
    .map(s => s.trim())
    .filter(s => s.length > 0);

  for (const statement of statements) {
    await connection.query(statement);
  }
  console.log('Schema ready.');

  console.log('Clearing old data...');
  await connection.query('SET FOREIGN_KEY_CHECKS = 0;');
  await connection.query('TRUNCATE TABLE wishlists;');
  await connection.query('TRUNCATE TABLE reviews;');
  await connection.query('TRUNCATE TABLE hotel_bookings;');
  await connection.query('TRUNCATE TABLE passengers;');
  await connection.query('TRUNCATE TABLE flight_bookings;');
  await connection.query('TRUNCATE TABLE train_bookings;');
  await connection.query('TRUNCATE TABLE bookings;');
  await connection.query('TRUNCATE TABLE room_types;');
  await connection.query('TRUNCATE TABLE hotels;');
  await connection.query('TRUNCATE TABLE flights;');
  await connection.query('TRUNCATE TABLE trains;');
  await connection.query('TRUNCATE TABLE stations;');
  await connection.query('TRUNCATE TABLE attractions;');
  await connection.query('TRUNCATE TABLE buses;');
  await connection.query('TRUNCATE TABLE car_rentals;');
  await connection.query('TRUNCATE TABLE insurances;');
  await connection.query('TRUNCATE TABLE airports;');
  await connection.query('TRUNCATE TABLE cities;');
  await connection.query('TRUNCATE TABLE users;');
  await connection.query('SET FOREIGN_KEY_CHECKS = 1;');

  console.log('Seeding cities...');
  const citiesData = [
    [1, 'Jakarta', 'Indonesia'],
    [2, 'Surabaya', 'Indonesia'],
    [3, 'Bali (Denpasar)', 'Indonesia'],
    [4, 'Yogyakarta', 'Indonesia'],
    [5, 'Bandung', 'Indonesia'],
    [6, 'Makassar', 'Indonesia'],
    [7, 'Medan', 'Indonesia'],
    [8, 'Balikpapan', 'Indonesia'],
    [9, 'Semarang', 'Indonesia'],
    [10, 'Solo', 'Indonesia']
  ];
  for (const c of citiesData) {
    await connection.query('INSERT INTO cities (id, name, country) VALUES (?, ?, ?)', c);
  }

  console.log('Seeding airports...');
  const airportsData = [
    [1, 'CGK', 'Soekarno-Hatta International Airport', 1],
    [2, 'HLP', 'Halim Perdanakusuma International Airport', 1],
    [3, 'SUB', 'Juanda International Airport', 2],
    [4, 'DPS', 'I Gusti Ngurah Rai International Airport', 3],
    [5, 'YIA', 'Yogyakarta International Airport', 4],
    [6, 'BDO', 'Husein Sastranegara International Airport', 5],
    [7, 'UPG', 'Sultan Hasanuddin International Airport', 6],
    [8, 'KNO', 'Kualanamu International Airport', 7],
    [9, 'BPN', 'Sultan Aji Muhammad Sulaiman Airport', 8]
  ];
  for (const a of airportsData) {
    await connection.query('INSERT INTO airports (id, code, name, city_id) VALUES (?, ?, ?, ?)', a);
  }

  console.log('Seeding flights for next 14 days...');
  const airlines = [
    { name: 'Garuda Indonesia', code: 'GA', priceMultiplier: 1.4 },
    { name: 'Batik Air', code: 'ID', priceMultiplier: 1.15 },
    { name: 'Citilink', code: 'QG', priceMultiplier: 1.0 },
    { name: 'Lion Air', code: 'JT', priceMultiplier: 0.85 },
    { name: 'Super Air Jet', code: 'IU', priceMultiplier: 0.88 },
    { name: 'Indonesia AirAsia', code: 'QZ', priceMultiplier: 0.92 }
  ];

  const popularRoutes = [
    { origin: 1, dest: 4, basePrice: 1200000, durationMins: 115 }, // CGK -> DPS
    { origin: 4, dest: 1, basePrice: 1250000, durationMins: 110 }, // DPS -> CGK
    { origin: 1, dest: 3, basePrice: 850000, durationMins: 90 },   // CGK -> SUB
    { origin: 3, dest: 1, basePrice: 870000, durationMins: 90 },   // SUB -> CGK
    { origin: 1, dest: 5, basePrice: 750000, durationMins: 70 },   // CGK -> YIA
    { origin: 5, dest: 1, basePrice: 760000, durationMins: 70 },   // YIA -> CGK
    { origin: 1, dest: 7, basePrice: 1400000, durationMins: 140 }, // CGK -> UPG
    { origin: 1, dest: 8, basePrice: 1350000, durationMins: 135 }, // CGK -> KNO
    { origin: 3, dest: 4, basePrice: 650000, durationMins: 60 },   // SUB -> DPS
    { origin: 4, dest: 3, basePrice: 660000, durationMins: 60 }    // DPS -> SUB
  ];

  const now = new Date();
  let flightCount = 0;

  for (let dayOffset = 0; dayOffset < 14; dayOffset++) {
    const flightDate = new Date(now.getTime() + dayOffset * 24 * 60 * 60 * 1000);
    const year = flightDate.getFullYear();
    const month = String(flightDate.getMonth() + 1).padStart(2, '0');
    const day = String(flightDate.getDate()).padStart(2, '0');
    const dateStr = `${year}-${month}-${day}`;

    for (const route of popularRoutes) {
      // Pick 2-3 airlines per route per day
      const times = [
        { hour: 6, min: 30 },
        { hour: 11, min: 15 },
        { hour: 16, min: 45 },
        { hour: 19, min: 20 }
      ];

      for (let i = 0; i < times.length; i++) {
        const airline = airlines[(dayOffset + i + route.origin) % airlines.length];
        const departTime = `${dateStr} ${String(times[i].hour).padStart(2, '0')}:${String(times[i].min).padStart(2, '0')}:00`;

        const departDateObj = new Date(`${dateStr}T${String(times[i].hour).padStart(2, '0')}:${String(times[i].min).padStart(2, '0')}:00`);
        const arriveDateObj = new Date(departDateObj.getTime() + route.durationMins * 60 * 1000);
        const arriveYear = arriveDateObj.getFullYear();
        const arriveMonth = String(arriveDateObj.getMonth() + 1).padStart(2, '0');
        const arriveDay = String(arriveDateObj.getDate()).padStart(2, '0');
        const arriveH = String(arriveDateObj.getHours()).padStart(2, '0');
        const arriveM = String(arriveDateObj.getMinutes()).padStart(2, '0');
        const arriveTime = `${arriveYear}-${arriveMonth}-${arriveDay} ${arriveH}:${arriveM}:00`;

        const flightNo = `${airline.code}-${100 + ((dayOffset * 13 + i * 7 + route.origin * 3) % 899)}`;
        const price = Math.round((route.basePrice * airline.priceMultiplier) / 10000) * 10000;
        const seats = 30 + ((dayOffset + i * 11) % 60);

        await connection.query(
          `INSERT INTO flights (airline, flight_no, origin_id, destination_id, depart_at, arrive_at, price, seats_available)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
          [airline.name, flightNo, route.origin, route.dest, departTime, arriveTime, price, seats]
        );
        flightCount++;
      }
    }
  }
  console.log(`Seeded ${flightCount} flights successfully.`);

  console.log('Seeding hotels and room types...');
  const hotelsData = [
    {
      name: 'The Mulia Resort & Villas Nusa Dua',
      city_id: 3,
      address: 'Jl. Raya Nusa Dua Selatan, Kawasan Sawangan, Nusa Dua, Bali',
      star: 5,
      rating: 4.9,
      image_url: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1000&q=80',
      description: 'Resor bintang 5 megah di tepi pantai Nusa Dua dengan kolam renang infinity tepi laut terbaik di Asia, spa mewah, dan restoran fine dining kelas dunia.',
      facilities: ['WiFi Gratis', 'Kolam Renang Infinity', 'Restoran Bintang 5', 'Pusat Kebugaran', 'Spa & Sauna', 'Akses Pantai Pribadi', 'Sarapan Prasmanan', 'Resepsionis 24 Jam'],
      rooms: [
        { name: 'Mulia Grandeur Room', price: 2850000, capacity: 2, total_rooms: 15 },
        { name: 'Royal Ocean View Suite', price: 4600000, capacity: 2, total_rooms: 8 },
        { name: 'Presidential Beachfront Villa', price: 9200000, capacity: 4, total_rooms: 3 }
      ]
    },
    {
      name: 'Padma Resort Ubud',
      city_id: 3,
      address: 'Banjar Carik, Desa Puhu Payangan, Ubud, Bali',
      star: 5,
      rating: 4.8,
      image_url: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=1000&q=80',
      description: 'Menikmati keasrian lembah sungai dan hutan bambu Ubud yang menakjubkan. Dilengkapi kolam renang air hangat dengan panorama kabut pagi.',
      facilities: ['WiFi Gratis', 'Kolam Renang Air Hangat', 'Yoga Deck', 'Spa Alami', 'Restoran Puhu', 'Jalur Sepeda Lembah', 'Antar Jemput Ubud'],
      rooms: [
        { name: 'Premier Club Room', price: 2350000, capacity: 2, total_rooms: 12 },
        { name: 'Forest View Valley Suite', price: 3800000, capacity: 3, total_rooms: 6 }
      ]
    },
    {
      name: 'Amnaya Resort Kuta',
      city_id: 3,
      address: 'Jl. Kartika Plaza Gang Puspa Ayu No. 99, Kuta, Bali',
      star: 4,
      rating: 4.7,
      image_url: 'https://images.unsplash.com/photo-1540541338287-41700207dee6?auto=format&fit=crop&w=1000&q=80',
      description: 'Oase ketenangan di tengah keramaian Kuta, hanya beberapa menit berjalan kaki dari Discovery Mall dan Pantai Kuta.',
      facilities: ['WiFi Gratis', 'Kolam Renang Luar Ruangan', 'Sukun Restaurant', 'Bhava Spa', 'Pusat Kebugaran'],
      rooms: [
        { name: 'Deluxe Heritage Room', price: 890000, capacity: 2, total_rooms: 20 },
        { name: 'Junior Suite with Balcony', price: 1450000, capacity: 2, total_rooms: 10 }
      ]
    },
    {
      name: 'Hotel Indonesia Kempinski Jakarta',
      city_id: 1,
      address: 'Jl. M.H. Thamrin No. 1, Menteng, Jakarta Pusat',
      star: 5,
      rating: 4.8,
      image_url: 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?auto=format&fit=crop&w=1000&q=80',
      description: 'Hotel bersejarah termegah di jantung Jakarta, menghadap langsung ke Bundaran HI dengan akses langsung ke Grand Indonesia Mall.',
      facilities: ['WiFi Cepat', 'Kolam Renang Rooftop', 'Paulaner Brauhaus', 'Kempinski The Spa', 'Pusat Kebugaran Modern', 'Parkir Valet Gratis'],
      rooms: [
        { name: 'Deluxe City View', price: 2150000, capacity: 2, total_rooms: 25 },
        { name: 'Grand Deluxe Bundaran HI View', price: 3100000, capacity: 2, total_rooms: 15 },
        { name: 'Kempinski Diplomatic Suite', price: 6500000, capacity: 4, total_rooms: 5 }
      ]
    },
    {
      name: 'ARTOTEL Suites Mangkuluhur Jakarta',
      city_id: 1,
      address: 'Jl. Gatot Subroto Kav 2-3, Semanggi, Jakarta Selatan',
      star: 4,
      rating: 4.6,
      image_url: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=1000&q=80',
      description: 'Konsep seni kontemporer memadukan kemewahan modern di kawasan strategis Gatot Subroto Semanggi.',
      facilities: ['WiFi Gratis', 'Kolam Renang Luar Ruangan', 'Galeri Seni', 'Restoran & Bar', 'Ruang Rapat'],
      rooms: [
        { name: 'Studio 30 King', price: 950000, capacity: 2, total_rooms: 30 },
        { name: 'Classic Executive Suite', price: 1750000, capacity: 2, total_rooms: 12 }
      ]
    },
    {
      name: 'Yats Colony Yogyakarta',
      city_id: 4,
      address: 'Jl. Patangpuluhan No. 23, Wirobrajan, Yogyakarta',
      star: 4,
      rating: 4.7,
      image_url: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=1000&q=80',
      description: 'Hotel bergaya urban santai bernuansa tropis dengan kolam renang sentral dan kafe bistro sehat yang sangat ramah foto.',
      facilities: ['WiFi Gratis', 'Kolam Renang Asri', 'Bistro Cafe Organik', 'Toko Oleh-oleh Kreatif', 'Persewaan Sepeda'],
      rooms: [
        { name: 'HA Room Garden Access', price: 650000, capacity: 2, total_rooms: 18 },
        { name: 'NA Room Mezzanine Pool View', price: 1100000, capacity: 3, total_rooms: 8 }
      ]
    },
    {
      name: 'The Phoenix Hotel Yogyakarta - MGallery',
      city_id: 4,
      address: 'Jl. Jenderal Sudirman No. 9, Jetis, Yogyakarta',
      star: 5,
      rating: 4.8,
      image_url: 'https://images.unsplash.com/photo-1564501049412-61c2a3083791?auto=format&fit=crop&w=1000&q=80',
      description: 'Perpaduan arsitektur kolonial klasik 1918 dan tradisi Jawa yang menawan, terletak dekat Tugu Jogja dan Malioboro.',
      facilities: ['WiFi Gratis', 'Kolam Renang Klasik', 'Paprika Restaurant', 'Spa Jawa Tradisional', 'Live Music Gamelan'],
      rooms: [
        { name: 'Superior Heritage Twin', price: 980000, capacity: 2, total_rooms: 20 },
        { name: 'Legacy Deluxe Balcony', price: 1550000, capacity: 2, total_rooms: 10 }
      ]
    },
    {
      name: 'Vasa Hotel Surabaya',
      city_id: 2,
      address: 'Jl. Mayjen HR. Muhammad No. 31, Sukomanunggal, Surabaya',
      star: 5,
      rating: 4.8,
      image_url: 'https://images.unsplash.com/photo-1618773928121-c32242e63f39?auto=format&fit=crop&w=1000&q=80',
      description: 'Hotel bintang 5 modern dengan fasilitas bisnis dan liburan terlengkap di Surabaya Barat.',
      facilities: ['WiFi Cepat', 'Kolam Renang Luar Ruang', 'Chamas Churrascaria', 'Xiang Fu Hai Dim Sum', 'Helipad'],
      rooms: [
        { name: 'Select Room King', price: 1150000, capacity: 2, total_rooms: 25 },
        { name: 'Executive Suite Lounge Access', price: 2300000, capacity: 2, total_rooms: 8 }
      ]
    },
    {
      name: 'The Papandayan Bandung',
      city_id: 5,
      address: 'Jl. Gatot Subroto No. 83, Malabar, Lengkong, Bandung',
      star: 5,
      rating: 4.7,
      image_url: 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?auto=format&fit=crop&w=1000&q=80',
      description: 'Hotel klasik dengan suasana sejuk khas Bandung, taman tropis asri, serta The Cellar Wine & Cheese.',
      facilities: ['WiFi Gratis', 'Kolam Renang Tropis', 'Cantigi Fine Dining', 'The Mirten Lounge', 'Pusat Kebugaran & Spa'],
      rooms: [
        { name: 'Classic King Room', price: 820000, capacity: 2, total_rooms: 20 },
        { name: 'Premier Garden Suite', price: 1450000, capacity: 2, total_rooms: 10 }
      ]
    },
    {
      name: 'Padma Hotel Bandung',
      city_id: 5,
      address: 'Jl. Ranca Bentang No. 56-58, Ciumbuleuit, Bandung',
      star: 5,
      rating: 4.9,
      image_url: 'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=1000&q=80',
      description: 'Dikelilingi perbukitan hijau Ciumbuleuit, menyajikan pemandangan bukit dramatis dengan teh sore gratis dan kolam renang pemanas.',
      facilities: ['WiFi Gratis', 'Kolam Renang Air Hangat Bukit', 'Afternoon Tea Gratis', 'Flying Fox & Outbound', 'Restoran Tebing Alam'],
      rooms: [
        { name: 'Deluxe Hill View Room', price: 1950000, capacity: 2, total_rooms: 15 },
        { name: 'Premier Mountain Suite', price: 3200000, capacity: 2, total_rooms: 6 }
      ]
    }
  ];

  for (const h of hotelsData) {
    const [result] = await connection.query(
      `INSERT INTO hotels (name, city_id, address, star, description, facilities, image_url, rating)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [h.name, h.city_id, h.address, h.star, h.description, JSON.stringify(h.facilities), h.image_url, h.rating]
    );
    const hotelId = result.insertId;

    for (const r of h.rooms) {
      await connection.query(
        `INSERT INTO room_types (hotel_id, name, price_per_night, capacity, total_rooms)
         VALUES (?, ?, ?, ?, ?)`,
        [hotelId, r.name, r.price, r.capacity, r.total_rooms]
      );
    }
  }
  console.log(`Seeded ${hotelsData.length} hotels with room types.`);

  console.log('Seeding sample users...');
  const salt = await bcrypt.genSalt(10);
  const passwordHash = await bcrypt.hash('password123', salt);

  const [budi] = await connection.query(
    `INSERT INTO users (name, email, phone, password_hash)
     VALUES (?, ?, ?, ?)`,
    ['Budi Santoso', 'budi@travelokuy.com', '081234567890', passwordHash]
  );
  const budiId = budi.insertId;

  await connection.query(
    `INSERT INTO users (name, email, phone, password_hash)
     VALUES (?, ?, ?, ?)`,
    ['Siti Rahma', 'siti@travelokuy.com', '081298765432', passwordHash]
  );

  console.log('Seeding reviews...');
  const reviewsData = [
    [1, budiId, 5, 'Pelayanan luar biasa, kolam renang tepi pantai sangat luas dan sarapannya nomor satu!'],
    [2, budiId, 5, 'Suasana Ubud yang sangat tenang, udara pagi berkabut sungguh menenangkan jiwa.'],
    [4, budiId, 5, 'Lokasi emas persis di seberang Bundaran HI, kamar sangat mewah dan nyaman.'],
    [6, budiId, 4, 'Desain sangat artsy dan instagramable. Menu kafe organik sangat lezat.']
  ];
  for (const rev of reviewsData) {
    await connection.query(
      `INSERT INTO reviews (hotel_id, user_id, rating, comment) VALUES (?, ?, ?, ?)`,
      rev
    );
  }

  console.log('Seeding sample bookings for demonstration...');
  // 1. Completed Flight Booking (PAID)
  const [flightRows] = await connection.query('SELECT * FROM flights LIMIT 1');
  if (flightRows.length > 0) {
    const flight = flightRows[0];
    const bookingCode = 'TL8K2M9QX';
    const [b1] = await connection.query(
      `INSERT INTO bookings (code, user_id, type, total_price, status, payment_method, paid_at, expires_at)
       VALUES (?, ?, 'FLIGHT', ?, 'PAID', 'BCA Virtual Account', NOW(), DATE_ADD(NOW(), INTERVAL 1 HOUR))`,
      [bookingCode, budiId, flight.price]
    );
    const bId = b1.insertId;
    await connection.query(
      `INSERT INTO flight_bookings (booking_id, flight_id, seats) VALUES (?, ?, 1)`,
      [bId, flight.id]
    );
    await connection.query(
      `INSERT INTO passengers (booking_id, title, full_name, id_number) VALUES (?, 'Tn', 'Budi Santoso', '3171012345670001')`,
      [bId]
    );
  }

  // 2. Completed Hotel Booking (PAID)
  const [roomRows] = await connection.query('SELECT * FROM room_types LIMIT 1');
  if (roomRows.length > 0) {
    const room = roomRows[0];
    const hotelCode = 'TL9P4X7BZ';
    const checkIn = new Date(now.getTime() + 2 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
    const checkOut = new Date(now.getTime() + 4 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
    const totalPrice = room.price_per_night * 2;

    const [b2] = await connection.query(
      `INSERT INTO bookings (code, user_id, type, total_price, status, payment_method, paid_at, expires_at)
       VALUES (?, ?, 'HOTEL', ?, 'PAID', 'GoPay', NOW(), DATE_ADD(NOW(), INTERVAL 1 HOUR))`,
      [hotelCode, budiId, totalPrice]
    );
    const bId = b2.insertId;
    await connection.query(
      `INSERT INTO hotel_bookings (booking_id, room_type_id, check_in, check_out, rooms, guests, guest_name)
       VALUES (?, ?, ?, ?, 1, 2, 'Budi Santoso')`,
      [bId, room.id, checkIn, checkOut]
    );
  }

  // 3. Pending Flight Booking for easy simulation payment test
  const [pendingFlightRows] = await connection.query('SELECT * FROM flights LIMIT 1 OFFSET 2');
  if (pendingFlightRows.length > 0) {
    const pFlight = pendingFlightRows[0];
    const pendingCode = 'TL3R5V1WY';
    const [b3] = await connection.query(
      `INSERT INTO bookings (code, user_id, type, total_price, status, payment_method, paid_at, expires_at)
       VALUES (?, ?, 'FLIGHT', ?, 'PENDING', NULL, NULL, DATE_ADD(NOW(), INTERVAL 1 HOUR))`,
      [pendingCode, budiId, pFlight.price]
    );
    const bId = b3.insertId;
    await connection.query(
      `INSERT INTO flight_bookings (booking_id, flight_id, seats) VALUES (?, ?, 1)`,
      [bId, pFlight.id]
    );
    await connection.query(
      `INSERT INTO passengers (booking_id, title, full_name, id_number) VALUES (?, 'Tn', 'Budi Santoso', '3171012345670001')`,
      [bId]
    );
  }

  // Wishlist item
  await connection.query(
    `INSERT INTO wishlists (user_id, hotel_id) VALUES (?, 1), (?, 2)`,
    [budiId, budiId]
  );

  console.log('Seeding train stations...');
  const stationsData = [
    [1, 'GMR', 'Stasiun Gambir', 1, 'KAI'],
    [2, 'PSE', 'Stasiun Pasar Senen', 1, 'KAI'],
    [3, 'HLM', 'Stasiun Halim (KCIC Whoosh)', 1, 'WHOOSH'],
    [4, 'BD', 'Stasiun Bandung', 5, 'KAI'],
    [5, 'TGL', 'Stasiun Tegalluar (KCIC Whoosh)', 5, 'WHOOSH'],
    [6, 'YK', 'Stasiun Yogyakarta (Tugu)', 4, 'KAI'],
    [7, 'SGU', 'Stasiun Surabaya Gubeng', 2, 'KAI'],
    [8, 'SLO', 'Stasiun Solo Balapan', 10, 'KAI'],
    [9, 'SMT', 'Stasiun Semarang Tawang', 9, 'KAI']
  ];
  for (const s of stationsData) {
    await connection.query('INSERT INTO stations (id, code, name, city_id, type) VALUES (?, ?, ?, ?, ?)', s);
  }

  console.log('Seeding trains for next 14 days...');
  const trainTemplates = [
    // Jakarta <-> Bandung (Whoosh)
    { name: 'Whoosh Kereta Cepat G1218', no: 'G1218', class: 'Kereta Cepat (Premium)', orig: 3, dest: 5, depH: 7, depM: 15, durM: 45, price: 250000 },
    { name: 'Whoosh Kereta Cepat G1226', no: 'G1226', class: 'Kereta Cepat (First Class)', orig: 3, dest: 5, depH: 9, depM: 45, durM: 45, price: 350000 },
    { name: 'Whoosh Kereta Cepat G1234', no: 'G1234', class: 'Kereta Cepat (Premium)', orig: 3, dest: 5, depH: 14, depM: 30, durM: 45, price: 250000 },
    { name: 'Whoosh Kereta Cepat G1242', no: 'G1242', class: 'Kereta Cepat (Premium)', orig: 3, dest: 5, depH: 17, depM: 35, durM: 45, price: 250000 },
    // Bandung <-> Jakarta (Whoosh)
    { name: 'Whoosh Kereta Cepat G1221', no: 'G1221', class: 'Kereta Cepat (Premium)', orig: 5, dest: 3, depH: 8, depM: 20, durM: 45, price: 250000 },
    { name: 'Whoosh Kereta Cepat G1237', no: 'G1237', class: 'Kereta Cepat (Premium)', orig: 5, dest: 3, depH: 15, depM: 35, durM: 45, price: 250000 },

    // Jakarta <-> Bandung (KAI)
    { name: 'Argo Parahyangan 36', no: 'KA-36', class: 'Eksekutif', orig: 1, dest: 4, depH: 6, depM: 30, durM: 180, price: 200000 },
    { name: 'Argo Parahyangan 40', no: 'KA-40', class: 'Ekonomi Premium', orig: 1, dest: 4, depH: 10, depM: 10, durM: 185, price: 150000 },
    { name: 'Argo Parahyangan 44', no: 'KA-44', class: 'Eksekutif Luxury', orig: 1, dest: 4, depH: 15, depM: 10, durM: 180, price: 380000 },
    { name: 'Argo Parahyangan 39', no: 'KA-39', class: 'Eksekutif', orig: 4, dest: 1, depH: 7, depM: 0, durM: 180, price: 200000 },
    { name: 'Argo Parahyangan 43', no: 'KA-43', class: 'Ekonomi Premium', orig: 4, dest: 1, depH: 16, depM: 10, durM: 185, price: 150000 },

    // Jakarta <-> Yogyakarta
    { name: 'Taksaka Pagi', no: 'KA-68', class: 'Eksekutif', orig: 1, dest: 6, depH: 9, depM: 20, durM: 390, price: 540000 },
    { name: 'Argo Dwipangga', no: 'KA-10', class: 'Eksekutif Luxury', orig: 1, dest: 6, depH: 8, depM: 50, durM: 380, price: 650000 },
    { name: 'Taksaka Malam', no: 'KA-70', class: 'Eksekutif', orig: 1, dest: 6, depH: 21, depM: 40, durM: 385, price: 540000 },
    { name: 'Taksaka Pagi (YK-GMR)', no: 'KA-67', class: 'Eksekutif', orig: 6, dest: 1, depH: 8, depM: 45, durM: 390, price: 540000 },
    { name: 'Bogowonto', no: 'KA-138', class: 'Eksekutif', orig: 2, dest: 6, depH: 9, depM: 50, durM: 430, price: 340000 },
    { name: 'Progo', no: 'KA-248', class: 'Ekonomi', orig: 2, dest: 6, depH: 22, depM: 30, durM: 450, price: 190000 },
    { name: 'Bogowonto (YK-PSE)', no: 'KA-137', class: 'Eksekutif', orig: 6, dest: 2, depH: 9, depM: 10, durM: 430, price: 340000 },
    { name: 'Progo (YK-PSE)', no: 'KA-247', class: 'Ekonomi', orig: 6, dest: 2, depH: 15, depM: 10, durM: 450, price: 190000 },

    // Jakarta <-> Surabaya
    { name: 'Argo Bromo Anggrek', no: 'KA-2', class: 'Eksekutif Luxury', orig: 1, dest: 7, depH: 8, depM: 20, durM: 490, price: 850000 },
    { name: 'Sembrani Malam', no: 'KA-64', class: 'Eksekutif', orig: 1, dest: 7, depH: 19, depM: 30, durM: 520, price: 680000 },
    { name: 'Argo Bromo Anggrek (SGU-GMR)', no: 'KA-1', class: 'Eksekutif Luxury', orig: 7, dest: 1, depH: 9, depM: 10, durM: 490, price: 850000 },
    { name: 'Gaya Baru Malam Selatan', no: 'KA-106', class: 'Ekonomi', orig: 2, dest: 7, depH: 11, depM: 0, durM: 660, price: 240000 },
    { name: 'Jayabaya', no: 'KA-108', class: 'Eksekutif', orig: 2, dest: 7, depH: 17, depM: 25, durM: 640, price: 420000 },
    { name: 'Gaya Baru Malam Selatan (SGU-PSE)', no: 'KA-105', class: 'Ekonomi', orig: 7, dest: 2, depH: 12, depM: 0, durM: 660, price: 240000 },

    // Jakarta <-> Semarang (SMT)
    { name: 'Argo Sindoro', no: 'KA-11', class: 'Eksekutif', orig: 1, dest: 9, depH: 16, depM: 40, durM: 310, price: 380000 },
    { name: 'Argo Muria', no: 'KA-13', class: 'Eksekutif Luxury', orig: 1, dest: 9, depH: 7, depM: 0, durM: 305, price: 520000 },
    { name: 'Argo Sindoro (SMT-GMR)', no: 'KA-12', class: 'Eksekutif', orig: 9, dest: 1, depH: 6, depM: 50, durM: 310, price: 380000 },
    { name: 'Menoreh', no: 'KA-226', class: 'Ekonomi Premium', orig: 2, dest: 9, depH: 18, depM: 50, durM: 340, price: 210000 },
    { name: 'Menoreh (SMT-PSE)', no: 'KA-225', class: 'Ekonomi Premium', orig: 9, dest: 2, depH: 8, depM: 0, durM: 340, price: 210000 },

    // Jakarta <-> Solo (SLO)
    { name: 'Argo Lawu', no: 'KA-7', class: 'Eksekutif Luxury', orig: 1, dest: 8, depH: 20, depM: 45, durM: 420, price: 620000 },
    { name: 'Argo Lawu (SLO-GMR)', no: 'KA-8', class: 'Eksekutif Luxury', orig: 8, dest: 1, depH: 8, depM: 30, durM: 420, price: 620000 },
    { name: 'Fajar Utama Solo', no: 'KA-88', class: 'Ekonomi Premium', orig: 2, dest: 8, depH: 5, depM: 45, durM: 470, price: 260000 },
    { name: 'Mataram (SLO-PSE)', no: 'KA-89', class: 'Eksekutif', orig: 8, dest: 2, depH: 18, depM: 50, durM: 460, price: 320000 },

    // Yogyakarta <-> Surabaya
    { name: 'Sancaka Pagi', no: 'KA-176', class: 'Ekonomi Premium', orig: 6, dest: 7, depH: 6, depM: 45, durM: 240, price: 230000 },
    { name: 'Sancaka Sore', no: 'KA-178', class: 'Eksekutif', orig: 6, dest: 7, depH: 16, depM: 40, durM: 240, price: 310000 },
    { name: 'Sancaka Siang (SGU-YK)', no: 'KA-175', class: 'Eksekutif', orig: 7, dest: 6, depH: 9, depM: 0, durM: 240, price: 310000 },
    { name: 'Sancaka Malam (SGU-YK)', no: 'KA-177', class: 'Ekonomi Premium', orig: 7, dest: 6, depH: 17, depM: 30, durM: 240, price: 230000 },

    // Bandung <-> Surabaya
    { name: 'Argo Wilis', no: 'KA-6', class: 'Eksekutif', orig: 4, dest: 7, depH: 7, depM: 45, durM: 590, price: 620000 },
    { name: 'Turangga Malam', no: 'KA-66', class: 'Eksekutif', orig: 4, dest: 7, depH: 18, depM: 10, durM: 610, price: 580000 },
    { name: 'Argo Wilis (SGU-BD)', no: 'KA-5', class: 'Eksekutif', orig: 7, dest: 4, depH: 8, depM: 15, durM: 590, price: 620000 },
    { name: 'Turangga (SGU-BD)', no: 'KA-65', class: 'Eksekutif', orig: 7, dest: 4, depH: 20, depM: 0, durM: 610, price: 580000 },

    // Solo <-> Surabaya
    { name: 'Sancaka Solo', no: 'KA-182', class: 'Eksekutif', orig: 8, dest: 7, depH: 7, depM: 30, durM: 190, price: 210000 },
    { name: 'Sancaka Solo (SGU-SLO)', no: 'KA-181', class: 'Eksekutif', orig: 7, dest: 8, depH: 15, depM: 0, durM: 190, price: 210000 },

    // Semarang <-> Surabaya
    { name: 'Ambarawa Ekspres', no: 'KA-232', class: 'Ekonomi Premium', orig: 9, dest: 7, depH: 8, depM: 30, durM: 260, price: 130000 },
    { name: 'Ambarawa Ekspres (SGU-SMT)', no: 'KA-231', class: 'Ekonomi Premium', orig: 7, dest: 9, depH: 13, depM: 20, durM: 260, price: 130000 }
  ];

  for (let day = 0; day < 14; day++) {
    const targetDate = new Date(now.getTime() + day * 24 * 60 * 60 * 1000);
    const y = targetDate.getFullYear();
    const m = String(targetDate.getMonth() + 1).padStart(2, '0');
    const d = String(targetDate.getDate()).padStart(2, '0');

    for (const t of trainTemplates) {
      const depStr = `${y}-${m}-${d} ${String(t.depH).padStart(2, '0')}:${String(t.depM).padStart(2, '0')}:00`;
      const depDate = new Date(`${y}-${m}-${d}T${String(t.depH).padStart(2, '0')}:${String(t.depM).padStart(2, '0')}:00`);
      const arrDate = new Date(depDate.getTime() + t.durM * 60 * 1000);
      const arrStr = `${arrDate.getFullYear()}-${String(arrDate.getMonth() + 1).padStart(2, '0')}-${String(arrDate.getDate()).padStart(2, '0')} ${String(arrDate.getHours()).padStart(2, '0')}:${String(arrDate.getMinutes()).padStart(2, '0')}:00`;
      const seats = Math.floor(Math.random() * 40) + 12;

      await connection.query(
        `INSERT INTO trains (train_name, train_no, class_type, origin_id, destination_id, depart_at, arrive_at, price, seats_available)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [t.name, t.no, t.class, t.orig, t.dest, depStr, arrStr, t.price, seats]
      );
    }
  }

  console.log('Seeding attractions, buses, cars, and insurances...');
  const attractionsData = [
    ['Dunia Fantasi (Dufan) Ancol', 'Taman Rekreasi & Wahana', 1, 'Jl. Lodan Timur No. 7, Ancol, Jakarta Utara', 4.8, 275000, 'https://images.unsplash.com/photo-1513889961551-628c1e5e2ee9?auto=format&fit=crop&w=800&q=80', 'Nikmati wahana seru pemacu adrenalin Halilintar, Tornado, Kora-Kora, dan Istana Boneka bersama keluarga.'],
    ['Taman Safari Indonesia Cisarua', 'Wisata Alam & Satwa', 1, 'Jl. Kapten Harun Kabir No. 724, Cibeureum, Bogor', 4.9, 225000, 'https://images.unsplash.com/photo-1534567153574-2b12153a87f0?auto=format&fit=crop&w=800&q=80', 'Sensasi safari berkeliling habitat satwa liar bebas dari dalam mobil, pertunjukan edukasi lumba-lumba, dan baby zoo.'],
    ['Waterbom Bali', 'Taman Rekreasi Air', 3, 'Jl. Kartika Plaza, Kuta, Badung, Bali', 4.9, 340000, 'https://images.unsplash.com/photo-1582650625119-3a31f841807d?auto=format&fit=crop&w=800&q=80', 'Waterpark nomor 1 di Asia dengan seluncuran kelas dunia Climax, Pipeline, dan kolam tropis yang rimbun.'],
    ['Candi Borobudur Sunrise Tour', 'Wisata Budaya & Sejarah', 4, 'Borobudur, Magelang, Jawa Tengah', 4.9, 150000, 'https://images.unsplash.com/photo-1596402184320-417e7178b2cd?auto=format&fit=crop&w=800&q=80', 'Menikmati matahari terbit magis dari candi Buddha terbesar di dunia peninggalan Dinasti Syailendra.'],
    ['Garuda Wisnu Kencana (GWK)', 'Taman Budaya', 3, 'Jl. Raya Uluwatu, Ungasan, Kuta Selatan, Bali', 4.7, 125000, 'https://images.unsplash.com/photo-1555400038-63f5ba517a47?auto=format&fit=crop&w=800&q=80', 'Mahakarya patung raksasa Dewa Wisnu setinggi 121 meter dengan tarian Kecak kolosal setiap sore.'],
    ['Trans Studio Bandung', 'Taman Rekreasi Indoor', 5, 'Jl. Gatot Subroto No. 289, Cibangkong, Bandung', 4.6, 200000, 'https://images.unsplash.com/photo-1576085898323-218337e3e43c?auto=format&fit=crop&w=800&q=80', 'Taman hiburan indoor ber-AC terlengkap di Bandung dengan wahana roller coaster indoor spektakuler.']
  ];
  for (const a of attractionsData) {
    await connection.query('INSERT INTO attractions (name, category, city_id, location, rating, price, image_url, description) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', a);
  }

  const busesData = [
    ['Rosalia Indah', 'Executive Plus (Pramugari)', 'Jakarta', 'Yogyakarta', '07:30', '16:30', 220000, 4.8, 18],
    ['Sinar Jaya', 'Suite Class Sleeper Bus', 'Jakarta', 'Surabaya', '18:00', '04:00', 360000, 4.9, 12],
    ['DAMRI', 'Royal Class', 'Jakarta', 'Bandung', '08:00', '11:30', 110000, 4.7, 24],
    ['Pahala Kencana', 'Executive', 'Jakarta', 'Bali (Denpasar)', '12:00', '13:00 (+1)', 480000, 4.6, 20],
    ['Harapan Jaya', 'Double Decker Super Luxury', 'Jakarta', 'Solo', '19:00', '04:30', 250000, 4.8, 16],
    ['Juragan 99 Trans', 'First Class Sleeper 21 Seat', 'Malang', 'Jakarta', '17:00', '05:00', 420000, 4.9, 8]
  ];
  for (const b of busesData) {
    await connection.query('INSERT INTO buses (operator_name, bus_class, origin_city, dest_city, departure_time, arrival_time, price, rating, seats_available) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', b);
  }

  const carsData = [
    ['Toyota All New Avanza', 'Manual', 7, 350000, 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=600&q=80', 'Mitra Rental Nusantara'],
    ['Toyota Kijang Innova Reborn', 'Otomatis', 7, 550000, 'https://images.unsplash.com/photo-1550355291-bbee04a92027?auto=format&fit=crop&w=600&q=80', 'TraveLokuy Express Rent'],
    ['Toyota Fortuner GR Sport', 'Otomatis', 7, 1100000, 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=600&q=80', 'Premium Rent Car Bali & Jogja'],
    ['Toyota HiAce Commuter Luxury', 'Manual', 14, 950000, 'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?auto=format&fit=crop&w=600&q=80', 'Wisata Group Transport'],
    ['Honda Brio Satya Facelift', 'Otomatis', 5, 280000, 'https://images.unsplash.com/photo-1590362891991-f776e747a588?auto=format&fit=crop&w=600&q=80', 'City Drive Rental']
  ];
  for (const c of carsData) {
    await connection.query('INSERT INTO car_rentals (car_name, transmission, capacity, price_per_day, image_url, provider_name) VALUES (?, ?, ?, ?, ?, ?)', c);
  }

  const insurancesData = [
    ['TraveLokuy Safe Basic', 'Domestik', 50000000, 25000, JSON.stringify(['Santunan Medis Darurat s.d Rp 50.000.000', 'Santunan Keterlambatan Perjalanan s.d Rp 2.000.000', 'Layanan Darurat 24 Jam'])],
    ['TraveLokuy Safe Gold', 'Domestik & Regional', 250000000, 55000, JSON.stringify(['Santunan Medis Darurat s.d Rp 250.000.000', 'Kerusakan / Kehilangan Bagasi s.d Rp 10.000.000', 'Kompensasi Delay Pesawat Rp 3.000.000', 'Bantuan Hotline Hukum & Medis Global'])],
    ['TraveLokuy Safe Platinum', 'Seluruh Dunia (Comprehensive)', 1000000000, 120000, JSON.stringify(['Santunan Medis Kelas VIP s.d Rp 1.000.000.000', 'Evakuasi Medis Udara Tanpa Batas', 'Kompensasi Pembatalan Perjalanan Penuh', 'Perlindungan Bencana Alam & Kecelakaan Pribadi'])]
  ];
  for (const ins of insurancesData) {
    await connection.query('INSERT INTO insurances (plan_name, category, max_coverage, price, benefits) VALUES (?, ?, ?, ?, ?)', ins);
  }

  // Sample Train Booking (PAID)
  const [trainRows] = await connection.query('SELECT * FROM trains WHERE train_name LIKE "%Whoosh%" LIMIT 1');
  if (trainRows.length > 0) {
    const whoosh = trainRows[0];
    const trainCode = 'TL5W8Q2KC';
    const [b4] = await connection.query(
      `INSERT INTO bookings (code, user_id, type, total_price, status, payment_method, paid_at, expires_at)
       VALUES (?, ?, 'TRAIN', ?, 'PAID', 'BCA Virtual Account', NOW(), DATE_ADD(NOW(), INTERVAL 1 HOUR))`,
      [trainCode, budiId, whoosh.price]
    );
    const bId = b4.insertId;
    await connection.query(
      `INSERT INTO train_bookings (booking_id, train_id, seats) VALUES (?, ?, 1)`,
      [bId, whoosh.id]
    );
    await connection.query(
      `INSERT INTO passengers (booking_id, title, full_name, id_number) VALUES (?, 'Tn', 'Budi Santoso', '3171012345670001')`,
      [bId]
    );
  }

  console.log('Database seeding successfully finished!');
  await connection.end();
  process.exit(0);
}

seed().catch(err => {
  console.error('Seed error:', err);
  process.exit(1);
});

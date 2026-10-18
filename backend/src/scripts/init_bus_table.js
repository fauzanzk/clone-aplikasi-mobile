const db = require('../config/db');

async function run() {
  await db.query(`
    CREATE TABLE IF NOT EXISTS bus_bookings (
      booking_id INT PRIMARY KEY,
      bus_id INT NOT NULL,
      seat_no INT NOT NULL,
      passenger_name VARCHAR(100),
      FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
      FOREIGN KEY (bus_id) REFERENCES buses(id) ON DELETE CASCADE
    )
  `);
  console.log('bus_bookings table created successfully');
  process.exit(0);
}

run().catch((e) => {
  console.error('Error creating bus_bookings table:', e.message);
  process.exit(1);
});

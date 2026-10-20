CREATE DATABASE IF NOT EXISTS traveloka_clone CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE traveloka_clone;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  phone VARCHAR(20),
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS cities (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  country VARCHAR(50) DEFAULT 'Indonesia'
);

CREATE TABLE IF NOT EXISTS airports (
  id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(3) NOT NULL UNIQUE,      -- CGK, SUB, DPS
  name VARCHAR(100) NOT NULL,
  city_id INT NOT NULL,
  FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS flights (
  id INT AUTO_INCREMENT PRIMARY KEY,
  airline VARCHAR(50) NOT NULL,         -- Garuda, Lion Air, dll.
  flight_no VARCHAR(10) NOT NULL,
  origin_id INT NOT NULL,
  destination_id INT NOT NULL,
  depart_at DATETIME NOT NULL,
  arrive_at DATETIME NOT NULL,
  price DECIMAL(12,2) NOT NULL,
  seats_available INT NOT NULL,
  INDEX idx_flight_search (origin_id, destination_id, depart_at),
  FOREIGN KEY (origin_id) REFERENCES airports(id) ON DELETE CASCADE,
  FOREIGN KEY (destination_id) REFERENCES airports(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS hotels (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  city_id INT NOT NULL,
  address VARCHAR(255),
  star TINYINT DEFAULT 3,
  description TEXT,
  facilities JSON,                      -- ["WiFi","Kolam Renang","Sarapan"]
  image_url VARCHAR(255),
  rating DECIMAL(2,1) DEFAULT 0,
  INDEX idx_hotel_city (city_id),
  FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS room_types (
  id INT AUTO_INCREMENT PRIMARY KEY,
  hotel_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,           -- Deluxe, Suite
  price_per_night DECIMAL(12,2) NOT NULL,
  capacity INT DEFAULT 2,
  total_rooms INT NOT NULL,
  FOREIGN KEY (hotel_id) REFERENCES hotels(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS bookings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(12) NOT NULL UNIQUE,     -- kode booking acak
  user_id INT NOT NULL,
  type VARCHAR(30) NOT NULL,            -- 'FLIGHT' | 'HOTEL' | 'TRAIN' | 'BUS' | 'XPERIENCE' | 'CAR_RENTAL' | 'AIRPORT_TRANSFER' | 'INSURANCE'
  total_price DECIMAL(14,2) NOT NULL,
  status VARCHAR(10) NOT NULL DEFAULT 'PENDING',  -- PENDING | PAID | CANCELLED | EXPIRED
  payment_method VARCHAR(30),
  paid_at TIMESTAMP NULL,
  expires_at DATETIME,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS flight_bookings (
  booking_id INT PRIMARY KEY,
  flight_id INT NOT NULL,
  seats INT NOT NULL,
  FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
  FOREIGN KEY (flight_id) REFERENCES flights(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS passengers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  booking_id INT NOT NULL,
  title VARCHAR(5),                     -- Tn, Ny, Nn
  full_name VARCHAR(100) NOT NULL,
  id_number VARCHAR(30),
  FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS hotel_bookings (
  booking_id INT PRIMARY KEY,
  room_type_id INT NOT NULL,
  check_in DATE NOT NULL,
  check_out DATE NOT NULL,
  rooms INT NOT NULL DEFAULT 1,
  guests INT NOT NULL DEFAULT 1,
  guest_name VARCHAR(100) NOT NULL,
  FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
  FOREIGN KEY (room_type_id) REFERENCES room_types(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS reviews (
  id INT AUTO_INCREMENT PRIMARY KEY,
  hotel_id INT NOT NULL,
  user_id INT NOT NULL,
  rating TINYINT NOT NULL,
  comment TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (hotel_id) REFERENCES hotels(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS wishlists (
  user_id INT NOT NULL,
  hotel_id INT NOT NULL,
  PRIMARY KEY (user_id, hotel_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (hotel_id) REFERENCES hotels(id) ON DELETE CASCADE
);

-- =============================================
-- LAYANAN LAINNYA: KERETA API, BUS, XPERIENCE, RENTAL, ASURANSI
-- =============================================

CREATE TABLE IF NOT EXISTS stations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(10) NOT NULL UNIQUE,     -- GMR, PSE, BD, YK, SGU, HLM, TGL
  name VARCHAR(100) NOT NULL,
  city_id INT NOT NULL,
  type VARCHAR(20) DEFAULT 'KAI',       -- 'KAI' | 'WHOOSH'
  FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS trains (
  id INT AUTO_INCREMENT PRIMARY KEY,
  train_name VARCHAR(100) NOT NULL,     -- Argo Bromo Anggrek, Whoosh KCIC, Taksaka
  train_no VARCHAR(20) NOT NULL,
  class_type VARCHAR(50) NOT NULL,      -- Eksekutif, Bisnis, Ekonomi, Kereta Cepat
  origin_id INT NOT NULL,
  destination_id INT NOT NULL,
  depart_at DATETIME NOT NULL,
  arrive_at DATETIME NOT NULL,
  price DECIMAL(12,2) NOT NULL,
  seats_available INT NOT NULL,
  INDEX idx_train_search (origin_id, destination_id, depart_at),
  FOREIGN KEY (origin_id) REFERENCES stations(id) ON DELETE CASCADE,
  FOREIGN KEY (destination_id) REFERENCES stations(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS train_bookings (
  booking_id INT PRIMARY KEY,
  train_id INT NOT NULL,
  seats INT NOT NULL,
  FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
  FOREIGN KEY (train_id) REFERENCES trains(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS attractions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  category VARCHAR(50) NOT NULL,        -- Taman Hiburan, Wisata Budaya, Waterpark
  city_id INT NOT NULL,
  location VARCHAR(255) NOT NULL,
  rating DECIMAL(2,1) DEFAULT 4.8,
  price DECIMAL(12,2) NOT NULL,
  image_url VARCHAR(255),
  description TEXT,
  FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS buses (
  id INT AUTO_INCREMENT PRIMARY KEY,
  operator_name VARCHAR(100) NOT NULL,  -- Rosalia Indah, Sinar Jaya, DAMRI
  bus_class VARCHAR(50) NOT NULL,       -- Executive Plus, Sleeper Class, Double Decker
  origin_city VARCHAR(100) NOT NULL,
  dest_city VARCHAR(100) NOT NULL,
  departure_time VARCHAR(20) NOT NULL,
  arrival_time VARCHAR(20) NOT NULL,
  price DECIMAL(12,2) NOT NULL,
  rating DECIMAL(2,1) DEFAULT 4.7,
  seats_available INT DEFAULT 24
);

CREATE TABLE IF NOT EXISTS bus_bookings (
  booking_id INT PRIMARY KEY,
  bus_id INT NOT NULL,
  seat_no INT NOT NULL,
  passenger_name VARCHAR(100),
  FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
  FOREIGN KEY (bus_id) REFERENCES buses(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS car_rentals (
  id INT AUTO_INCREMENT PRIMARY KEY,
  car_name VARCHAR(100) NOT NULL,       -- Avanza, Innova Reborn, Fortuner, HiAce
  transmission VARCHAR(20) NOT NULL,    -- Manual, Otomatis
  capacity INT NOT NULL,
  price_per_day DECIMAL(12,2) NOT NULL,
  image_url VARCHAR(255),
  provider_name VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS insurances (
  id INT AUTO_INCREMENT PRIMARY KEY,
  plan_name VARCHAR(100) NOT NULL,      -- Travel Safe Basic, Gold, Platinum
  category VARCHAR(50) NOT NULL,        -- Domestik, Internasional
  max_coverage DECIMAL(14,2) NOT NULL,
  price DECIMAL(12,2) NOT NULL,
  benefits JSON
);

CREATE TABLE IF NOT EXISTS service_bookings (
  booking_id INT PRIMARY KEY,
  service_type VARCHAR(30) NOT NULL,    -- 'XPERIENCE' | 'CAR_RENTAL' | 'AIRPORT_TRANSFER' | 'INSURANCE'
  item_name VARCHAR(150) NOT NULL,
  item_subtitle VARCHAR(255),
  details JSON,
  FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE
);

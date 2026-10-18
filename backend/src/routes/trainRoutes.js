const express = require('express');
const router = express.Router();
const { getStations, searchTrains, getTrainById } = require('../controllers/trainController');
const { createTrainBooking } = require('../controllers/bookingController');
const { authMiddleware } = require('../middleware/auth');

router.get('/stations', getStations);
router.get('/', searchTrains);
router.get('/:id', getTrainById);
router.post('/book', authMiddleware, createTrainBooking);

module.exports = router;

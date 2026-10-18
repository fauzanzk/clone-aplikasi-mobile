const express = require('express');
const router = express.Router();
const {
  createFlightBooking,
  createHotelBooking,
  createTrainBooking,
  payBooking,
  cancelBooking,
  getUserBookings,
  getBookingDetail
} = require('../controllers/bookingController');
const { authMiddleware } = require('../middleware/auth');

// All booking routes require user authentication
router.use(authMiddleware);

router.post('/flight', createFlightBooking);
router.post('/hotel', createHotelBooking);
router.post('/train', createTrainBooking);
router.post('/:id/pay', payBooking);
router.post('/:id/cancel', cancelBooking);
router.get('/', getUserBookings);
router.get('/:id', getBookingDetail);

module.exports = router;

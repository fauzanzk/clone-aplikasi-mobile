const express = require('express');
const router = express.Router();
const { searchHotels, getHotelById } = require('../controllers/hotelController');
const { addReview } = require('../controllers/reviewController');
const { authMiddleware, optionalAuth } = require('../middleware/auth');

router.get('/', searchHotels);
router.get('/:id', optionalAuth, getHotelById);
router.post('/:id/reviews', authMiddleware, addReview);

module.exports = router;

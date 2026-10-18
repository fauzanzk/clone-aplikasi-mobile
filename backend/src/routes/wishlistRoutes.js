const express = require('express');
const router = express.Router();
const { getWishlist, toggleWishlist, removeWishlist } = require('../controllers/wishlistController');
const { authMiddleware } = require('../middleware/auth');

router.use(authMiddleware);

router.get('/', getWishlist);
router.post('/:hotelId', toggleWishlist);
router.delete('/:hotelId', removeWishlist);

module.exports = router;

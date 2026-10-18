const express = require('express');
const router = express.Router();
const { searchFlights, getFlightById } = require('../controllers/flightController');

router.get('/', searchFlights);
router.get('/:id', getFlightById);

module.exports = router;

const express = require('express');
const router = express.Router();
const { getBuses, getAttractions, getCars, getInsurances } = require('../controllers/serviceController');

router.get('/buses', getBuses);
router.get('/attractions', getAttractions);
router.get('/cars', getCars);
router.get('/insurances', getInsurances);

module.exports = router;

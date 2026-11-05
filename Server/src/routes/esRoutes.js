const express = require('express');
const router = express.Router();
const esController = require('../controllers/esController');

// Pastikan fungsi handler tidak undefined
router.get('/search', esController.search);
router.get('/analytics/geo', esController.getGeoAnalytics);

module.exports = router;
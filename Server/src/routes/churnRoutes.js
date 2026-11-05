const express = require('express');
const router = express.Router();
const churnController = require('../controllers/churnController');

router.get('/stats', churnController.getChurnStats);
router.post('/predict', churnController.predictCustomerChurn);

module.exports = router;
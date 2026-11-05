const ESModel = require('../models/esModel');

const search = async (req, res) => {
  try {
    const { q } = req.query;
    if (!q) return res.status(400).json({ success: false, message: 'Query q dibutuhkan' });
    
    const results = await ESModel.searchCustomers(q);
    res.status(200).json({ success: true, count: results.length, data: results });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getGeoAnalytics = async (req, res) => {
  try {
    const buckets = await ESModel.getGeoAggregation();
    res.status(200).json({ success: true, data: buckets });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = {
  search,
  getGeoAnalytics
};
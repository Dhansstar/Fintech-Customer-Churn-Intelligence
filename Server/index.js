const express = require('express');
const cors = require('cors');
require('dotenv').config();

const churnRoutes = require('./src/routes/churnRoutes');
const esRoutes = require('./src/routes/esRoutes');

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// Routing API
app.use('/api/v1/churn', churnRoutes);
app.use('/api/v1/search', esRoutes);

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'OK', message: 'Fintech Analytics API Online' });
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
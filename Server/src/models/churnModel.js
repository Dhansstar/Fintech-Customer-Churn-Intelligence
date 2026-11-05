const pool = require('../config/db');

class ChurnModel {
  static async getCustomerDetails(customerId) {
    const query = `
      SELECT 
        c.customer_id, c.credit_score, c.geography, c.gender, c.age, c.estimated_salary,
        a.tenure, a.num_of_products, a.has_cr_card, a.is_active_member,
        f.balance, f.exited
      FROM fact_customer_churn f
      JOIN dim_customer c ON f.customer_id = c.customer_id
      JOIN dim_account a ON f.customer_id = a.customer_id
      WHERE c.customer_id = $1;
    `;
    const { rows } = await pool.query(query, [customerId]);
    return rows[0];
  }

  static async getOverviewStats() {
    const query = `
      SELECT 
        COUNT(*) as total_customers,
        SUM(exited) as total_churned,
        ROUND(AVG(balance)::numeric, 2) as avg_balance
      FROM fact_customer_churn;
    `;
    const { rows } = await pool.query(query);
    return rows[0];
  }
}

module.exports = ChurnModel;
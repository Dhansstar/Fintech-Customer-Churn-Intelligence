const esClient = require('../config/elasticsearch');

class ESModel {
  static async searchCustomers(keyword) {
    const result = await esClient.search({
      index: 'bank_customers',
      body: {
        query: {
          multi_match: {
            query: keyword,
            fields: ['Geography', 'Gender', 'CustomerId']
          }
        }
      }
    });
    return result.hits.hits.map(hit => hit._source);
  }

  static async getGeoAggregation() {
    const result = await esClient.search({
      index: 'bank_customers',
      body: {
        size: 0,
        aggs: {
          by_geography: {
            terms: { field: 'Geography.keyword' },
            aggs: {
              churn_rate: { avg: { field: 'Exited' } }
            }
          }
        }
      }
    });
    return result.aggregations.by_geography.buckets;
  }
}

module.exports = ESModel;
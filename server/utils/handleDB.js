const pool = require('../db');

const handleDB = async (procedure, params = []) => {
  try {
    const client = await pool.connect();

    const placeholders = params.map((_, index) => `$${index + 1}`).join(', ');
    const query = `SELECT ${procedure}(${placeholders}) AS result;`;
    const result = await client.query(query, params);

    client.release();

    return result.rows[0].result;
  } catch (err) {
    console.error('Ошибка в handleDB:', err);
    return { status: 'error', message: err.message };
  }
};

module.exports = handleDB;

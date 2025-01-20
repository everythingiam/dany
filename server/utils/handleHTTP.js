const handleDB = require('./handleDB');

const handleHTTP = async (res, dbFunction, params, successMessage) => {
  try {
    const result = await handleDB(dbFunction, params);

    if (result.status === 'success') {
      res.status(200).json({
        status: 'success',
        message: `HTTP: ${successMessage || 'Operation successful'}`,
        dataDB: result,
      });
    } else {
      res.status(400).json({
        status: 'error',
        message: `DB: ${result.message}`,
      });
    }

    return result; 
  } catch (error) {
    console.error('Error in handleHTTP:', error);
    res.status(500).json({
      status: 'error',
      message: 'Internal server error',
    });

    return { status: 'error', message: 'Internal server error' };
  }
};

module.exports = handleHTTP;

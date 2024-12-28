const formSchema = require('../utils/schemas');

module.exports = validateForm = async (req, res, next) => {
  try {
    const formData = req.body;
    await formSchema.validate(formData);
    next();
  } catch (err) {
    console.log(err.errors);
    return res.status(422).json({
      status: 'error',
      message: 'Validation failed',
      errors: err.errors,
    });
  }
};

const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const validateFormMiddleware = require('../middleware/ValidateFormMiddleware');

router.post('/registration', validateFormMiddleware, userController.registration);
router.post('/login', validateFormMiddleware, userController.login);
router.get('/logout', userController.logout);
router.get('/check', userController.check);

module.exports = router;

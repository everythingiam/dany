const express = require('express');
const router = express.Router();
// const yup = require('yup');
const validateForm = require('../controllers/validateForm');


router.post('/login', (req, res) => {
  validateForm(req, res);
})

router.post('/registration', (req, res) => {
  console.log('Запрос получен на /auth/registration');
  validateForm(req, res);
})

module.exports = router;
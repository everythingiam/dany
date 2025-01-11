const express = require('express');
const router = express.Router();
const performFunction = require('../utils/performFunction');

class userController {
  async registration(req, res) {
    const { nickname, password } = req.body;
    const result = await performFunction('register_user', [nickname, password]);

    console.log('Registration result:', result);

    if (result.status === 'success') {
      res.cookie('session_token', result.data.token, {
        httpOnly: true,
        secure: process.env.ENVIRONMENT === 'production',
        sameSite: 'strict',
        maxAge: 24 * 60 * 60 * 1000, // 1 день
      });

      console.log(
        'User registered successfully with token:',
        result.data.token
      );

      return res.status(200).json({
        status: 'success',
        message: 'User registered successfully',
      });
    } else {
      return res.status(400).json({ status: 'error', message: result.message });
    }
  }

  async login(req, res) {
    const { nickname, password } = req.body;
    const result = await performFunction('authorize_user', [
      nickname,
      password,
    ]);

    console.log('Login result:', result);

    if (result.status === 'success') {
      res.cookie('session_token', result.data.token, {
        httpOnly: true,
        secure: process.env.ENVIRONMENT === 'production',
        sameSite: 'strict',
        maxAge: 24 * 60 * 60 * 1000, // 1 день
      });

      console.log('User logged successfully with token:', result.data.token);

      return res.status(200).json({
        status: 'success',
        message: 'User logged successfully',
      });
    } else {
      return res.status(400).json({ status: 'error', message: result.message });
    }
  }

  async logout(req, res) {
    const token = req.cookies.session_token;

    console.log('Logout attempt received. Token:', token);

    if (!token) {
      console.log('Error: No session token provided');
      return res.status(400).json({
        status: 'error',
        message: 'No session token provided',
      });
    }

    const result = await performFunction('logout_user', [token]);

    console.log('Logout result:', result);

    if (result.status === 'success') {
      res.clearCookie('session_token', {
        httpOnly: true,
        secure: process.env.ENVIRONMENT === 'production',
        sameSite: 'strict',
      });

      console.log('User logged out successfully, token cleared');

      return res.status(200).json({
        status: 'success',
        message: 'User logged out successfully',
      });
    } else {
      console.log('Error during logout:', result.message);
      return res.status(400).json({
        status: 'error',
        message: result.message,
      });
    }
  }

  async getUserData(req, res) {
    const token = req.cookies.session_token;

    if (!token) {
      console.log('Error: No session token provided');
      return res.status(400).json({
        status: 'error',
        message: 'No session token provided',
      });
    }

    const result = await performFunction('get_user_data', [token]);

    if (result.status === 'success') {
      return res.status(200).json({
        status: 'success',
        data: result,
      });
    } else {
      return res.status(400).json({
        status: 'error',
        message: result.message,
      });
    }
  }

  async check(req, res) {
    const token = req.cookies.session_token;

    if (!token) {
      console.log('Error: No session token provided');
      return res.status(400).json({
        status: 'error',
        message: 'No session token provided',
      });
    }

    const result = await performFunction('check_user', [token]);

    console.log('Check result from DB:', result);

    if (result.status === 'success') {
      return res.status(200).json({
        status: 'success',
        message: 'User is authorized',
      });
    } else {
      return res.status(400).json({
        status: 'error',
        message: result.message,
      });
    }
  }

  async updateAvatar(req, res) {
    const token = req.cookies.session_token;
    const avatar  = req.body.avatar;

    const result = await performFunction('update_user_avatar', [token, avatar]);

    if (result.status === 'success') {
      return res.status(200).json({
        status: 'success',
        message: 'User logged successfully',
      });
    } else {
      return res.status(400).json({ status: 'error', message: result.message });
    }
  }
}

module.exports = new userController();

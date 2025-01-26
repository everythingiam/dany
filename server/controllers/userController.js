const express = require('express');
const router = express.Router();
const handleDB = require('../utils/handleDB');
const handleHTTP = require('../utils/handleHTTP');

class userController {
  async registration(req, res) {
    const { nickname, password } = req.body;
    const result = await handleDB('register_user', [nickname, password]);

    if (result.status === 'success') {
      res.cookie('session_token', result.token, {
        httpOnly: true,
        secure: process.env.ENVIRONMENT === 'production',
        sameSite: 'strict',
        maxAge: 3 * 24 * 60 * 60 * 1000, // 3 дня
      });

      res.cookie('login', nickname, {
        httpOnly: true,
        secure: process.env.ENVIRONMENT === 'production',
        sameSite: 'strict',
        maxAge: 3 * 24 * 60 * 60 * 1000, // 3 дня
      });

      return res.status(200).json({
        status: 'success',
        message: `User ${nickname} registered`,
      });
    } else {
      return res.status(400).json({
        status: 'error',
        message: result.message,
      });
    }
  }

  async login(req, res) {
    const { nickname, password } = req.body;
    const result = await handleDB('authorize_user', [nickname, password]);

    console.log('LOGIN RESULT IN USERCONTROLLER', result);

    if (result.status === 'success') {
      res.cookie('session_token', result.token, {
        httpOnly: true,
        secure: process.env.ENVIRONMENT === 'production',
        sameSite: 'strict',
        maxAge: 3 * 24 * 60 * 60 * 1000, // 3 дня
      });

      res.cookie('login', nickname, {
        httpOnly: true,
        secure: process.env.ENVIRONMENT === 'production',
        sameSite: 'strict',
        maxAge: 3 * 24 * 60 * 60 * 1000, // 3 дня
      });

      return res.status(200).json({
        status: 'success',
        message: `User ${nickname} logged`,
        dataDB: 'logged',
      });
    } else {
      return res.status(400).json({
        status: 'error',
        message: result.message,
      });
    }
  }

  async logout(req, res) {
    const token = req.cookies.session_token;

    const result = await handleDB('logout_user', [token]);
    if (result.status === 'success') {
      res.clearCookie('session_token', {
        httpOnly: true,
        secure: process.env.ENVIRONMENT === 'production',
        sameSite: 'strict',
      });
      res.clearCookie('login', {
        httpOnly: true,
        secure: process.env.ENVIRONMENT === 'production',
        sameSite: 'strict',
      });

      return res.status(200).json({
        status: 'success',
        message: 'User logged out',
      });
    } else {
      return res.status(400).json({
        status: 'error',
        message: result.message,
      });
    }
  }

  async getUserData(req, res) {
    const token = req.cookies.session_token;
    return handleHTTP(res, 'get_user_data', [token], 'User data retrieved');
  }

  async check(req, res) {
    const token = req.cookies.session_token;
    return handleHTTP(res, 'check_user', [token], 'User data retrieved');
  }

  async updateAvatar(req, res) {
    const token = req.cookies.session_token;
    const avatar = req.body.avatar;
    return handleHTTP(
      res,
      'update_user_avatar',
      [token, avatar],
      'Avatar updated'
    );
  }

  async getLoginCookie(req, res) {
    const login = req.cookies.login;
    res.status(200).json({
      status: 'success',
      message: 'Operation successful',
      login: login
    });
  }
}

module.exports = new userController();

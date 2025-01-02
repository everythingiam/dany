const express = require('express');
const router = express.Router();
const performFunction = require('../utils/performFunction');

class gamesController {
  async getGames(req, res) {
    // const token = req.cookies.session_token;
    const token = '9966c122-8fc2-435a-95ed-090db54ea6b4';
    
    if (!token) {
      console.log('Error: No session token provided');
      return res.status(400).json({
        status: 'error',
        message: 'No session token provided',
      });
    }

    const result = await performFunction('get_active_games', [token]);

    console.log('Get games result:', result);

    if (result.status === 'success') {
      return res.status(200).json({
        data: result.data.active_games
      });
    } else {
      return res.status(400).json({
        status: 'error',
        message: result.message,
      });
    }
  }
}

module.exports = new gamesController();


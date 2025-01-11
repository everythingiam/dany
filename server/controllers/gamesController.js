const express = require('express');
const router = express.Router();
const performFunction = require('../utils/performFunction');

class gamesController {
  async getGames(req, res) {
    const token = req.cookies.session_token;

    const result = await performFunction('get_active_games', [token]);

    if (result.status === 'success') {
      return res.status(200).json({
        data: result.data.active_games,
      });
    } else {
      return res.status(400).json({
        status: 'error',
        message: result.message,
      });
    }
  }

  async getGameData(req, res) {
    const user_token = req.cookies.session_token; 
    const game_token = req.params.token; 

    const result = await performFunction('get_game_data', [
      user_token,
      game_token,
    ]);

    if (result) {
      return res.status(200).json({
        data: result,
      });
    } else {
      return res.status(400).json({
        status: 'error',
        message: result.message,
      });
    }
  }

  async joinRoom(req, res) {
    const user_token = req.cookies.session_token; 
    const game_token = req.params.token; 

    const result = await performFunction('join_room', [
      user_token,
      game_token,
    ]);

    if (result.status === 'success') {
      return res.status(200).json({
        data: result.data,
      });
    } else {
      return res.status(400).json({
        status: 'error',
        message: result.message,
      });
    }
  }

  async leaveRoom(req, res) {
    const user_token = req.cookies.session_token; 
    const game_token = req.params.token; 

    const result = await performFunction('leave_room', [
      user_token,
      game_token,
    ]);

    if (result.status === 'success') {
      return res.status(200).json({
        data: result.data,
      });
    } else {
      return res.status(400).json({
        status: 'error',
        message: result.message,
      });
    }
  }

  async makeDecision(req, res) {
    const user_token = req.cookies.session_token; 
    const game_token = req.params.token; 
    const word = req.body.word;

    const result = await performFunction('make_decision', [
      user_token,
      game_token,
      word,
    ]);

    if (result.status === 'success') {
      return res.status(200).json({
        data: result.data,
      });
    } else {
      return res.status(400).json({
        status: 'error',
        message: result.message,
      });
    }
  }

  async getPlayers(req, res) {
    const user_token = req.cookies.session_token; 
    const game_token = req.params.token; 

    const result = await performFunction('get_players', [
      user_token,
      game_token,
    ]);

    console.log(result);

    if (result.status === 'success') {
      return res.status(200).json({
        data: result.players,
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

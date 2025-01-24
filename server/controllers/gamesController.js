const express = require('express');
const router = express.Router();
const handleDB = require('../utils/handleDB');
const handleHTTP = require('../utils/handleHTTP');

class gamesController {
  async getGames(req, res) {
    const token = req.cookies.session_token;
    return handleHTTP(res, 'get_active_games', [token]);
  }

  async getGameData(req, res) {
    const userToken = req.cookies.session_token;
    const gameToken = req.params.token;
    return handleHTTP(res, 'get_game_data', [userToken, gameToken]);
  }

  async joinRoom(req, res) {
    const userToken = req.cookies.session_token;
    const gameToken = req.params.token;
    return handleHTTP(res, 'join_room', [userToken, gameToken]);
  }

  async leaveRoom(req, res) {
    const userToken = req.cookies.session_token;
    const gameToken = req.params.token;
    return handleHTTP(res, 'leave_room', [userToken, gameToken]);
  }

  async makeDecision(req, res) {
    const userToken = req.cookies.session_token;
    const gameToken = req.params.token;
    const word = req.body.word;
    return handleHTTP(res, 'make_decision', [userToken, gameToken, word]);
  }

  async getPlayers(req, res) {
    const userToken = req.cookies.session_token;
    const gameToken = req.params.token;
    return handleHTTP(res, 'get_players', [userToken, gameToken]);
  }

  async endLayout(req, res) {
    const userToken = req.cookies.session_token;
    const gameToken = req.params.token;
    const result = handleHTTP(res, 'end_layout', [userToken, gameToken]);
    console.log(result);
    return result;
  }

  async createRoom(req, res) {
    const userToken = req.cookies.session_token;
    const { name, number, speed } = req.body;
    return handleHTTP(res, 'create_game_room', [userToken, name, number, speed]);
  }
}

module.exports = new gamesController();

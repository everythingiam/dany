const express = require('express');
const router = express.Router();
const gamesController = require('../controllers/gamesController');

router.get('/', gamesController.getGames);
router.get('/:token', gamesController.getGameData);
router.get('/join_room/:token', gamesController.joinRoom);
router.get('/leave_room/:token', gamesController.leaveRoom);
router.get('/get_players/:token', gamesController.getPlayers);
router.post('/make_decision/:token', gamesController.makeDecision);

module.exports = router;

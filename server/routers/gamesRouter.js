const express = require('express');
const router = express.Router();
const gamesController = require('../controllers/gamesController');
const checkCookieMiddleware = require('../middleware/CheckCookieMiddleware')

router.get('/', checkCookieMiddleware, gamesController.getGames);
router.get('/:token', checkCookieMiddleware, gamesController.getGameData);
router.get('/join_room/:token', checkCookieMiddleware, gamesController.joinRoom);
router.get('/leave_room/:token', checkCookieMiddleware, gamesController.leaveRoom);
router.get('/get_players/:token', checkCookieMiddleware, gamesController.getPlayers);
router.get('/end_layout/:token', checkCookieMiddleware, gamesController.endLayout);
router.post('/make_decision/:token', checkCookieMiddleware, gamesController.makeDecision);
router.post('/create_room', checkCookieMiddleware, gamesController.createRoom);

module.exports = router;

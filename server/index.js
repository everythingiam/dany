const express = require('express');
const app = express();
const session = require('express-session');
const cookieParser = require('cookie-parser');
const cors = require('cors');
const WSServer = require('express-ws')(app);
const aWss = WSServer.getWss();
const helmet = require('helmet');
const userRouter = require('./routers/userRouter');
const gamesRouter = require('./routers/gamesRouter');
const server = require('http').createServer(app);
require('dotenv').config();

app.ws('/', (ws, req) => {
  ws.on('message', (msg) => {
    msg = JSON.parse(msg);
    switch (msg.method) {
      case 'connection':
        connectionHandler(ws, msg);
        break;
      case 'chatConnection':
        connectionHandler(ws, msg);
        break;
      case 'draw':
        broadcastConnection(ws, msg);
        break;
      case 'message':
        broadcastConnection(ws, msg);
        break;
    }
  });
});

const connectionHandler = (ws, msg) => {
  ws.id = msg.id;
  broadcastConnection(ws, msg);
};

const broadcastConnection = (ws, msg) => {
  aWss.clients.forEach((client) => {
    if (client.id === msg.id) {
      client.send(JSON.stringify(msg));
    }
  });
};

const allowedOrigins = [
  `http://localhost:${process.env.CLIENT_PORT || 5173}`,
  'https://danygame.vercel.app',
];

app.use(helmet());
app.use(
  cors({
    origin: 'https://danygame.vercel.app',
    credentials: true,
    methods: ['GET', 'POST', 'OPTIONS'],
  })
);
app.use(express.json());
app.use(cookieParser());
app.use('/user', userRouter);
app.use('/games', gamesRouter);
app.use(
  session({
    secret: process.env.SECRET_KEY,
    resave: false,
    saveUninitialized: false,
    cookie: {
      domain: '.vercel.app',
      httpOnly: true,
      secure: process.env.ENVIRONMENT === 'production',
      sameSite: 'none', 
      maxAge: 7 * 24 * 60 * 60 * 1000, // 1 неделя
    },
  })
);

app.listen(process.env.SERVER_PORT || 4000, () => {
  console.log('Server is listening on port 4000');
});
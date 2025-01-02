const express = require('express');
const app = express();
const session = require('express-session');
const cookieParser = require('cookie-parser');
const cors = require('cors');
const helmet = require('helmet');
const userRouter = require('./routers/userRouter');
const gamesRouter = require('./routers/gamesRouter');
const server = require('http').createServer(app);
const errorHandler = require('./middleware/ErrorHandlingMiddleware')
require('dotenv').config();

app.use(helmet());
app.use(
  cors({
    origin: `http://localhost:${process.env.CLIENT_PORT || 5173}`,
    credentials: true,
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
      httpOnly: true, 
      secure: process.env.NODE_ENV === 'production', 
      maxAge: 7 * 24 * 60 * 60 * 1000, // 1 неделя
    },
  })
);

app.use(errorHandler);

server.listen(process.env.SERVER_PORT || 4000, () => {
  console.log('Server is listening on port 4000');
});

import axios from 'axios';

export default class GamesService {
  static async getGames() {
    const response = await axios.get('http://localhost:4000/games/', {
      withCredentials: true,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    return response.data;
  }

  static async getGameData(token) {
    const response = await axios.get('http://localhost:4000/games/' + token, {
      withCredentials: true,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {
        token: token,
      },
    });

    return response.data;
  }

  static async joinRoom(token) {
    const response = await axios.get(
      `http://localhost:4000/games/join_room/${token}`, // токен в URL
      {
        withCredentials: true,
        headers: {
          'Content-Type': 'application/json',
        },
      }
    );

    return response.data;
  }

  static async leaveRoom(token) {
    const response = await axios.get(
      `http://localhost:4000/games/leave_room/${token}`, // токен в URL
      {
        withCredentials: true,
        headers: {
          'Content-Type': 'application/json',
        },
      }
    );

    return response.data;
  }

  static async makeDecision(token, word) {
    const response = await axios.post(
      `http://localhost:4000/games/make_decision/${token}`, { word }, 
      {
        withCredentials: true,
        headers: {
          'Content-Type': 'application/json',
        },
      }
    );

    return response;
  }

  static async getPlayers(token) {
    const response = await axios.get(
      `http://localhost:4000/games/get_players/${token}`, 
      {
        withCredentials: true,
        headers: {
          'Content-Type': 'application/json',
        },
      }
    );

    return response.data;
  }

  static async createRoom(number, speed, name) {
    const response = await axios.post(
      `http://localhost:4000/games/create_room/`, {number, speed, name}, 
      {
        withCredentials: true,
        headers: {
          'Content-Type': 'application/json',
        },
      }
    );

    return response.data;
  }

}

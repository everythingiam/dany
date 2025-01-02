import axios from 'axios';

export default class GamesService {
  static async getGames(){
    const response = await axios.get(
      'http://localhost:4000/games/',
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
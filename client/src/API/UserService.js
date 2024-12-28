import axios from 'axios';

export default class UserService {
  static async postRegistration(values) {
    const response = await axios.post(
      'http://localhost:4000/user/registration', values, 
      {
        withCredentials: true, 
        headers: {
          'Content-Type': 'application/json', 
        },
      }
    );

    return response.data;
  }

  static async postLogin(values) {
    const response = await axios.post(
      'http://localhost:4000/user/login', values, 
      {
        withCredentials: true, 
        headers: {
          'Content-Type': 'application/json', 
        },
      }
    );

    return response.data;
  }

  static async logout() {
    const response = await axios.get(
      'http://localhost:4000/user/logout',
      {
        withCredentials: true, 
        headers: {
          'Content-Type': 'application/json', 
        },
      }
    );

    return response.data;
  }

  static async check() {
    const response = await axios.get(
      'http://localhost:4000/user/check',
      {
        withCredentials: true, 
        headers: {
          'Content-Type': 'application/json', 
        },
      }
    );

    if (response.data.status === 'success'){
      return 'user';
    } else return null;
  }
}
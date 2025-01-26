import axios from 'axios';

const API_BASE_URL = 'https://dany-production-api.up.railway.app/user/';
// const API_BASE_URL = 'http://localhost:4000/user/';

const api = axios.create({
  baseURL: API_BASE_URL,
  withCredentials: true,
  headers: {
    'Content-Type': 'application/json',
  },
});

export default class UserService {
  static async postRegistration(values) {
    return this.#request('post', '/registration', values);
  }

  static async postLogin(values) {
    return this.#request('post', '/login', values);
  }

  static async logout() {
    return this.#request('get', '/logout');
  }

  static async check() {
    const response = await this.#request('get', '/check');
    if (response.data.status === 'success') {
      return 'user';
    } else return null;
  }

  static async getUserData() {
    return this.#request('get', '/get_user_data');
  }

  static async updateAvatar(avatar) {
    return this.#request('post', '/update_avatar', { avatar });
  }

  static async getLoginCookie() {
    return this.#request('get', `/get_login_cookie/`);
  }

  static async #request(method, url, data, params) {
    try {
      const config = { method, url, data, params };
      const response = await api(config);

      if (response.data.dataDB) {
        return response.data.dataDB;
      }
      return response.data;
    } catch (error) {
      console.error(`Ошибка запроса:`, error);
      return { status: 'error', message: error.message };
    }
  }
}

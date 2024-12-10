import Person from '../assets/person.svg';
import { Link } from 'react-router-dom';

const Registration = () => {
  return (
    <section className='login'>
      <img src={Person} alt="danysvg" />
      <h1>Зарегистрироваться</h1>
      <p>или {'\u00A0'}<Link to="/login">войти в аккаунт</Link></p>
      <form action="">
        <ul>
          <li>
            <input type="text" placeholder='Почта или никнейм'/>
          </li>
          <li>
            <input type="password" placeholder='Пароль'/>
          </li>
          <li>
            <button className='btn'>Зарегистрироваться</button>
          </li>
        </ul>
      </form>
    </section>
  )
};

export default Registration;

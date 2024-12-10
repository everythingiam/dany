import Dany from '../assets/dany.svg';
import { Link } from 'react-router-dom';


const Login = () => {
  return (
    <section className='login'>
      <img src={Dany} alt="danysvg" />
      <h1>Войти</h1>
      <p>или {'\u00A0'}<Link to="/registration">создать аккаунт</Link></p>
      <form action="">
        <ul>
          <li>
            <input type="text" placeholder='Почта или никнейм'/>
          </li>
          <li>
            <input type="password" placeholder='Пароль'/>
          </li>
          <li>
            <button className='btn'>Войти</button>
          </li>
        </ul>
      </form>
      <Link to="/recovery">Забыли пароль?</Link>
    </section>
  )
};

export default Login;

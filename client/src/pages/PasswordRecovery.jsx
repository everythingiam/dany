import Person from '../assets/cry-cat.gif';
import { Link, useNavigate } from 'react-router-dom';

const PasswordRecovery = () => {
  const navigate = useNavigate()
  return (
    <section className='login'>
      <img src={Person} alt="danysvg" />
      <h1>Очень жаль</h1>
      <p>или {'\u00A0'}<Link to="/login">войти в аккаунт</Link></p>
      <form action="">
        <ul>
          <li>
            <input type="text" placeholder='Просто так заполните поле'/>
          </li>
          <li>
            <button className='btn' onClick={() => navigate('/login')}>Отправить</button>
          </li>
        </ul>
      </form>
    </section>
  )
};

export default PasswordRecovery;

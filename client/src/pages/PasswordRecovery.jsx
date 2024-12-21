import Person from '../assets/sticker.gif';
import { Link } from 'react-router-dom';

const PasswordRecovery = () => {
  return (
    <section className='login'>
      <img src={Person} alt="danysvg" />
      <h1>Идите нахуй</h1>
      <p>или {'\u00A0'}<Link to="/login">войти в аккаунт</Link></p>
      <form action="">
        <ul>
          {/* <li>
            <input type="text" placeholder='Почта или никнейм'/>
          </li> */}
          <li>
            <button className='btn'>Я понял</button>
          </li>
        </ul>
      </form>
    </section>
  )
};

export default PasswordRecovery;

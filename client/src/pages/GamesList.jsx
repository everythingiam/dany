import { useNavigate } from 'react-router-dom';
import GameItem from '../components/GameItem';
import { useAuth } from '../hooks/useAuth';
import UserService from '../API/UserService';

const GamesList = () => {
  const { signout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = async () => {
    const response = await UserService.logout();

    if (response.status === 'success') {
      signout(() => navigate('/login', { replace: true }));
    }
  };

  return (
    <section className="games">
      <h1>Игровые комнаты</h1>
      <button className="btn">Создать свою игру</button>
      <button className="btn" onClick={handleLogout}>
        Выйти из аккаунта
      </button>
      {/* <p className='or'>Или подключиться к чужой</p> */}
      <GameItem
        title="Для крутых чуваков"
        creator="kuchinmd"
        currentplayers={4}
        maxplayers={5}
        speed={'Медленная'}
      />
      <GameItem
        title="Для крутых чуваков"
        creator="kuchinmd"
        currentplayers={4}
        maxplayers={5}
        speed={'Медленная'}
      />
      <GameItem
        title="Для крутых чуваков"
        creator="kuchinmd"
        currentplayers={4}
        maxplayers={5}
        speed={'Медленная'}
      />
    </section>
  );
};

export default GamesList;

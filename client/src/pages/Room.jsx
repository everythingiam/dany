import '../styles/room.scss';
import TopBar from '../components/TopBar';
import PlayersList from '../components/PlayersList';
import CardsCanvas from '../components/CardsCanvas';
import RoleTabs from '../components/RoleTabs';
import Chat from '../components/Chat';
import { useNavigate, useParams } from 'react-router-dom';
import { useFetching } from '../hooks/useFetching';
import GamesService from '../API/GamesService';
import useIntervalQuery from '../hooks/useIntervalQuery';
import { useEffect, useState } from 'react';
import Modal from 'react-bootstrap/Modal';
import Dany from '../assets/dany.svg';
import Person from '../assets/person.svg';
import UserService from '../API/UserService';
import LayoutTip from '../components/LayoutTip';

const Room = () => {
  const params = useParams();
  const navigate = useNavigate();
  const [data, setData] = useState(null);
  const [login, setLogin] = useState('');
  const [show, setShow] = useState(false);
  const [score, setScore] = useState({ dany: 0, persons: 0 });
  const [winner, setWinner] = useState(null);
  const [started, setStarted] = useState(false);

  const [fetchGameData, isLoading] = useFetching(async () => {
    const response = await GamesService.getGameData(params.token);
    // console.log(response);
    if (response.dany_wins || response.person_wins) {
      setScore({
        dany: response.dany_wins,
        persons: response.person_wins,
      });
    }
    setStarted(true);

    if (response.status === 'error') {
      setShow(true);
      if (!started) {
        navigate('/');
      }

      if (!winner && score.dany >= 3) {
        setScore((prev) => ({ ...prev, dany: prev.dany + 1 }));
        setWinner('Победа за: Дэни');
      } else if (!winner && score.persons >= 5) {
        setScore((prev) => ({ ...prev, persons: prev.persons + 1 }));
        setWinner('Победа за: Личности');
      } else if (!winner) {
        setWinner('Стало слишком мало игроков');
      }
    }

    setData(response);
  });

  useIntervalQuery(fetchGameData, 4000);

  useEffect(() => {
    const getLogin = async () => {
      const response = await UserService.getUserData();
      setLogin(response.login);
    };

    getLogin();
  }, []);

  const joinRoom = async () => {
    await GamesService.joinRoom(params.token);
  };

  if (isLoading || !data) {
    return <div>Loading...</div>;
  }

  const isPlayerActive =
    data.phase_name === 'layout' && data.active_person === login;

  const isGameStarted = data.phase_name !== 'waiting';

  const isPlayerInGame = data.players && data.players.includes(login);

  return (
    <>
      <main className="game-room">
        <div className="left">
          <TopBar data={data} token={params.token} />
          {isGameStarted && (
            <CardsCanvas data={data} token={params.token} login={login} />
          )}
          {isPlayerActive ? (
            <LayoutTip data={data} token={params.token} fetch={fetchGameData} />
          ) : (
            <PlayersList data={data} token={params.token} />
          )}
          {!isPlayerInGame && !isGameStarted && (
            <button className="btn join" onClick={joinRoom}>
              Присоединиться к игре
            </button>
          )}
        </div>
        <div className="right">
          <Chat data={data} token={params.token} />
          <RoleTabs data={data} token={params.token} fetch={fetchGameData} />
        </div>
      </main>

      <Modal show={show} onHide={() => setShow(false)}>
        <h1>Игра окончена</h1>
        <h1>{winner}</h1>
        <div className="score">
          <img src={Dany} alt="Dany" />
          <p className="klyakson">
            {score ? `${score.dany} : ${score.persons}` : '0 : 0'}
          </p>
          <img src={Person} alt="Person" />
        </div>
        <button className="btn" onClick={() => navigate('/')}>
          Вернуться к списку комнат
        </button>
      </Modal>
    </>
  );
};

export default Room;

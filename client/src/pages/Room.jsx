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
import UserService from '../API/UserService';

const Room = () => {
  const params = useParams();
  const navigate = useNavigate();
  const [flag, setFlag] = useState(false);
  const [data, setData] = useState(null);
  const [login, setLogin] = useState('');

  const [fetchGameData, isLoading] = useFetching(async () => {
    const response = await GamesService.getGameData(params.token);
    if (response.data.status === 'error') {
      navigate('/');
    }

    setData(response.data);
    (response.data.phase_name === 'layout') ? setFlag(true) : setFlag(false);
  });

  useIntervalQuery(fetchGameData, 4000);

  useEffect(() => {
    const getLogin = async () => {
      const response = await UserService.getUserData();
      setLogin(response.data.login);
    }

    getLogin();
  }, [])

  if (isLoading || !data) {
    return <div>Loading...</div>;
  }

  return (
    <>
      <main className="game-room">
        <div className="left">
          <TopBar data={data} token={params.token} />
          {data.phase_name !== 'waiting' && (
            <CardsCanvas data={data} token={params.token} flag={flag} login={login}/>
          )}
          <PlayersList data={data} token={params.token} />
        </div>
        <div className="right">
          <Chat data={data} token={params.token} />
          <RoleTabs data={data} token={params.token} />
        </div>
      </main>
    </>
  );
};

export default Room;

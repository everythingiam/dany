import PlayerItem from './PlayerItem';
import GamesService from '../API/GamesService';
import { useEffect, useState } from 'react';
import { useFetching } from '../hooks/useFetching';

const PlayersList = ({ data, token }) => {
  const [players, setPlayers] = useState([]);

  const [fetchUserData] = useFetching(async () => {
    const response = await GamesService.getPlayers(token);
    setPlayers(response.players); 
  });

  useEffect(() => {
    fetchUserData();
  }, [data.players]);

  return (
    <section className="players">
      {players && players.length > 0 ? ( 
        players.map((player) => (
          <PlayerItem key={player.login} player={player} data={data} />
        ))
      ) : (
        <p>Загрузка игроков...</p> 
      )}
    </section>
  );
};

export default PlayersList;

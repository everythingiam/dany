import PlayerItem from './PlayerItem';
import GamesService from '../API/GamesService';
import { useEffect, useState } from 'react';
import { useFetching } from '../hooks/useFetching';

const PlayersList = ({ data, token }) => {
  const [players, setPlayers] = useState([]);

  const [fetchUserData] = useFetching(async () => {
    const response = await GamesService.getPlayers(token);
    setPlayers(response.data);
  });

  useEffect(() => {
    fetchUserData();
  }, [data.players]);

  return (
    <section className="players">
      {players.map((player) => (
        <PlayerItem key={player.login} player={player} data={data} />
      ))}
    </section>
  );
};

export default PlayersList;

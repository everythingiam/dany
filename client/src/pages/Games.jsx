import GameList from '../components/GameList';
import { useEffect, useState } from 'react';
import GamesService from '../API/GamesService';
import { useFetching } from '../hooks/useFetching';

const Games = () => {
  const [array, setArray] = useState([]);
  const [fetchGames, isLoading] = useFetching(async () => {
    const response = await GamesService.getGames();
    setArray(response.data);
  });

  useEffect(() => {
    fetchGames();
  }, []);

  return (
    isLoading ? (<h1>Loading..</h1>) : (
      <section className="games">
        <h1>Игровые комнаты</h1>
        <button className="btn">Создать свою игру</button>
        <GameList array={array} />
      </section>
    )
  );
};

export default Games;

import GameList from '../components/GameList';
import { useState } from 'react';
import GamesService from '../API/GamesService';
import { useFetching } from '../hooks/useFetching';
import useIntervalQuery from '../hooks/useIntervalQuery';

const Games = () => {
  const [array, setArray] = useState([]);
  const [fetchGames, isLoading] = useFetching(async () => {
    const response = await GamesService.getGames();
    const newGames = response.data;
    if (JSON.stringify(newGames) !== JSON.stringify(array)) {
      setArray(newGames);
    }
  });

  useIntervalQuery(fetchGames, 4000);

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

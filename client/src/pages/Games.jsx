import GameList from '../components/GameList';
import { useState } from 'react';
import GamesService from '../API/GamesService';
import { useFetching } from '../hooks/useFetching';
import useIntervalQuery from '../hooks/useIntervalQuery';
import Create from '../components/Create';

const Games = () => {
  const [array, setArray] = useState([]);
  const [modalShow, setModalShow] = useState(false);

  const [fetchGames, isLoading] = useFetching(async () => {
    const response = await GamesService.getGames();
    const newGames = response.active_games;
    if (JSON.stringify(newGames) !== JSON.stringify(array)) {
      setArray(newGames);
    }
  });

  useIntervalQuery(fetchGames, 3000);

  return isLoading ? (
    <h1>Loading..</h1>
  ) : (
    <section className="games">
      <h1>Игровые комнаты</h1>
      <button className="btn" onClick={() => setModalShow(true)}>
        Создать свою игру
      </button>
      <Create show={modalShow} onHide={() => setModalShow(false)}/>
      <GameList array={array} />
    </section>
  );
};

export default Games;

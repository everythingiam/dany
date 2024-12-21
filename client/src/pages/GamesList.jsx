import GameItem from '../components/GameItem';

const GamesList = () => {
  return (
    <section className="games">
      <button className="btn">Создать свою игру</button>
      <p className='or'>Или подключиться к чужой</p>
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

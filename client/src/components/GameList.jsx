import GameItem from "./GameItem";

const GameList = ({array}) => {
  if (array.length === 0) {
    return <h1 style={{ textAlign: 'center' }}>Игры не найдены!</h1>;
  }

  return (
    <>
      {array.map(game => <GameItem key={game.room_token} game={game}/>)}
    </>
  )
};

export default GameList;

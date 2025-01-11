import { Link } from "react-router-dom";
import GamesService from "../API/GamesService";

const GameItem = ({ game }) => {
  const handleClick = async () => {
    await GamesService.joinRoom(game.room_token);
  }

  return (
    <Link to={`/${game.room_token}`} onClick={handleClick}>
      <div>
        <h2>{ game.room_name }</h2>
        <p>{ game.creator_login }</p>
      </div>
      <div>
        <p className="players">{ game.current_amount } / { game.max_amount }</p>
      </div>
      <div>
        <p className="speed">{ game.speed }</p>
      </div>
    </Link>
  )
};

export default GameItem;

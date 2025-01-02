import { Link } from "react-router-dom";

const GameItem = ({ game}) => {
  return (
    <Link to="/">
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

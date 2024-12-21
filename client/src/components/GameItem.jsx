import { Link } from "react-router-dom";

const GameItem = ({ title, creator, currentplayers, maxplayers, speed}) => {
  return (
    <Link to="/">
      <div>
        <h2>{ title }</h2>
        <p>{ creator }</p>
      </div>
      <div>
        <p className="players">{ currentplayers } / { maxplayers }</p>
      </div>
      <div>
        <p className="speed">{ speed }</p>
      </div>
    </Link>
  )
};

export default GameItem;

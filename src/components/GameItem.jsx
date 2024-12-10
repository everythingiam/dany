const GameItem = ({ title, creator, currentplayers, maxplayers, speed}) => {
  return (
    <article>
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
    </article>
  )
};

export default GameItem;

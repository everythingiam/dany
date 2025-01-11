

const PlayerItem = ({ player, data }) => {
  
  return (
    <div>
      <img
        src={`/avatars/${player.avatar}`}
        alt=""
        className={
          data.active_person === player.login
            ? 'active'
            : data.decisive_person === player.login
            ? 'decisive'
            : ''
        }
      />
      <p>{player.login}</p>
    </div>
  );
};

export default PlayerItem;

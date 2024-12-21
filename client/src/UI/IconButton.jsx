import Question from '../assets/question.svg';
import Info from '../assets/info.svg';
import Empty from '../assets/empty.svg';

const IconButton = ({ icon, text }) => {
  return (
    <button className="icon-btn">
      {icon === 'question' ? (
        <img src={Question} className="icon" />
      ) : icon === 'info' ? (
        <img src={Info} className="icon" />
      ) : <img src={Empty} className="icon" />}
      {text}
    </button>
  );
};

export default IconButton;

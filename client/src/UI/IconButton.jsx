import Question from '../assets/question.svg';
import Info from '../assets/info.svg';
import Empty from '../assets/empty.svg';
import ArrowLeft from '../assets/arrow-left.svg'

const IconButton = ({ icon, text, ...props }) => {
  return (
    <button className="icon-btn" {...props}>
      {icon === 'question' ? (
        <img src={Question} className="icon" />
      ) : icon === 'info' ? (
        <img src={Info} className="icon" />
      ) : icon === 'arrow-left' ? (
        <img src={ArrowLeft} className="icon" />

      ) : <img src={Empty} className="icon" />}
      {text}
    </button>
  );
};

export default IconButton;

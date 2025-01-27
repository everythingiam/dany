import Question from '../assets/question.svg';
import Info from '../assets/info.svg';
import Empty from '../assets/empty.svg';
import ArrowLeft from '../assets/arrow-left.svg';
import ProgressiveImage from '../components/ProgressiveImage';
import placeholderSrc from '../assets/white.svg';
import Leave from '../assets/leave.svg';

const IconButton = ({ icon, src, text, ...props }) => {
  return (
    <button className="icon-btn" {...props}>
      {icon === 'question' ? (
        <img src={Question} />
      ) : icon === 'info' ? (
        <img src={Info} />
      ) : icon === 'arrow-left' ? (
        <img src={ArrowLeft} />
      ) : icon === 'leave' ? (
        <img src={Leave} />
      ) : icon === 'avatar' ? (
        <ProgressiveImage src={src} placeholderSrc={placeholderSrc} className="icon avatar" />
      ) : <img src={Empty} />}
      {text}
    </button>
  );
};

export default IconButton;

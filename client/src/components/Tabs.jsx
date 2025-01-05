import { useState } from 'react';
import Dantcard from '../assets/danycard.svg';

const Tabs = ({p_state}) => {
  const [state, setState] = useState('role');

  return (
    <div className='tabs'>
      <img src={Dantcard} alt="" />
    </div>
  )
};

export default Tabs;

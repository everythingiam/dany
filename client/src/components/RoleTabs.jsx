import Danycard from '../assets/danycard.svg';
import { Tab, Tabs, TabList, TabPanel } from 'react-tabs';

const RoleTabs = () => {
  return (
    <Tabs defaultIndex={2} onSelect={(index) => console.log(index)}>
      <TabList>
        <Tab>Слова</Tab>
        <Tab>Моя роль</Tab>
      </TabList>
      <TabPanel>
        <div className="words">
          <ul className="klyakson">
            <li>
              <button>1 · внутренний покой</button>
            </li>
            <li>
              <button>2 · душа</button>
            </li>
            <li>
              <button>3 · сожаление</button>
            </li>
            <li>
              <button>4 · восточный</button>
            </li>
            <li>
              <button>5 · планета</button>
            </li>
          </ul>
        </div>
      </TabPanel>
      <TabPanel>
        <div className='card'>
          <img src={Danycard} alt="" />
        </div>
      </TabPanel>
    </Tabs>
  );
};

export default RoleTabs;

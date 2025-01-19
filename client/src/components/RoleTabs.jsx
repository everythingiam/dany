import Danycard from '../assets/danycard.svg';
import Personcard from '../assets/personcard.svg';
import Emptycard from '../assets/emptycard.svg';
import { Tab, Tabs, TabList, TabPanel } from 'react-tabs';
import GamesService from '../API/GamesService';

const RoleTabs = ({ data, token, fetch }) => {
  const handleClick = async (word) => {
    await GamesService.makeDecision(token, word);
    fetch();
  };

  return (
    <Tabs defaultIndex={2} onSelect={(index) => console.log(index)}>
      {data.player_role && (
        <TabList>
          <Tab>Моя роль</Tab>
          <Tab>Слова</Tab>
        </TabList>
      )}
      <TabPanel>
        <div className="card">
          {data.player_role === 'dany' ? (
            <img src={Danycard} alt="" />
          ) : data.player_role === 'person' ? (
            <img src={Personcard} alt="" />
          ) : (
            <img src={Emptycard} alt="" />
          )}
        </div>
      </TabPanel>
      <TabPanel>
        {data.player_role && (
          <div className="words">
            <ul className="klyakson">
              {data.ingame_words.map((word, index) => (
                <li key={word}>
                  <button
                    onClick={() => handleClick(word)}
                    className={word === data.active_word ? 'active' : ''}
                    disabled={
                      data.decisive_person !== data.player_login ||
                      data.phase_name !== 'decision'
                    }
                  >
                    {index + 1} · {word}
                  </button>
                </li>
              ))}
            </ul>
          </div>
        )}
      </TabPanel>
    </Tabs>
  );
};

export default RoleTabs;

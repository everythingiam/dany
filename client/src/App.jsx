import AppRouter from './components/AppRouter';
import './styles/common.scss';
import { AuthProvider } from './hoc/AuthProvider';
import { useState, useEffect } from 'react';
import ScreenOverlay from './components//ScreenOverlay';

const App = () => {
  const [isSmallScreen, setIsSmallScreen] = useState(window.innerWidth < 1000);

  const handleResize = () => {
    setIsSmallScreen(window.innerWidth < 1000);
  };

  useEffect(() => {
    window.addEventListener('resize', handleResize);
    
    return () => {
      window.removeEventListener('resize', handleResize);
    };
  }, []);

  return (
    <AuthProvider>
      {isSmallScreen && <ScreenOverlay />}
      <AppRouter />
    </AuthProvider>
  );
};

export default App;

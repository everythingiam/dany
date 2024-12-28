// import { useEffect } from 'react';
import AppRouter from './components/AppRouter';
// import UserService from './API/UserService';
// import { useAuth } from './hooks/useAuth';
import { AuthProvider } from './hoc/AuthProvider';

const App = () => {
  return (
    <AuthProvider>
      <AppRouter />
    </AuthProvider>
  );
};

export default App;

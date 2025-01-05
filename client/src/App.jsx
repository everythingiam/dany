import AppRouter from './components/AppRouter';
import './styles/common.scss';
import { AuthProvider } from './hoc/AuthProvider';

const App = () => {
  return (
    <AuthProvider>
      <AppRouter />
    </AuthProvider>
  );
};

export default App;

import { useEffect, useState, useContext } from "react";
import { Navigate, useLocation } from "react-router-dom";
import { AuthContext } from "../hoc/AuthProvider";
import UserService from "../API/UserService";

const RequireAuth = ({ children }) => {
  const { signin } = useContext(AuthContext);
  const [loading, setLoading] = useState(true); 
  const [isAuthenticated, setIsAuthenticated] = useState(false); 
  const location = useLocation();

  useEffect(() => {
    const checkAuth = async () => {
      try {
        const userData = await UserService.check();
        if (userData) {
          signin(userData, () => {}); 
          setIsAuthenticated(true); 
        }
      } catch (error) {
        console.error("Ошибка проверки авторизации:", error);
        setIsAuthenticated(false);
      } finally {
        setLoading(false); 
      }
    };

    checkAuth();
  }, []);

  if (loading) {
    return <div>Loading...</div>; 
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  return children;
};

export default RequireAuth;

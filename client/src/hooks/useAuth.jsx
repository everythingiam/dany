import { AuthContext } from "../hoc/AuthProvider";
import { useContext } from "react";

export const useAuth = () => {
  return useContext(AuthContext);
};
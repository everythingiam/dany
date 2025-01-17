import Dany from '../assets/dany.svg';
import { Link } from 'react-router-dom';
import { useFormik } from 'formik';
import { formSchema } from '../utils/schemas';
import UserService from '../API/UserService';
import { useAuth } from '../hooks/useAuth';

const Login = () => {
  const { signin } = useAuth();

  const onSubmit = async (values, actions) => {
    const vals = { ...values };
    actions.resetForm();
    const response = await UserService.postLogin(vals);
    if (response) {
    signin(values.nickname, () => window.location.href = '/');
    }
  };

  const { values, touched, isSubmitting, handleChange, handleSubmit, errors } =
    useFormik({
      initialValues: {
        nickname: '',
        password: '',
      },
      validationSchema: formSchema,
      onSubmit,
    });

  return (
    <section className="login">
      <img src={Dany} alt="danysvg" />
      <h1>Войти</h1>
      <p>
        или {'\u00A0'}
        <Link to="/registration">создать аккаунт</Link>
      </p>
      <form action="" onSubmit={handleSubmit}>
        <ul>
          <li>
            <input
              type="text"
              placeholder="Никнейм"
              onChange={handleChange}
              id="nickname"
              name="nickname"
              value={values.nickname}
              className={
                errors.nickname && touched.nickname ? 'input-error' : ''
              }
            />
            {errors.nickname && touched.nickname && (
              <span className="error">{errors.nickname}</span>
            )}
          </li>
          <li>
            <input
              type="password"
              placeholder="Пароль"
              onChange={handleChange}
              id="password"
              name="password"
              value={values.password}
              className={
                errors.password && touched.password ? 'input-error' : ''
              }
            />
            {errors.password && touched.password && (
              <span className="error">{errors.password}</span>
            )}
          </li>
          <li>
            <button type="submit" disabled={isSubmitting} className="btn">
              Войти
            </button>
          </li>
        </ul>
      </form>
      <Link to="/recovery">Забыли пароль?</Link>
    </section>
  );
};

export default Login;

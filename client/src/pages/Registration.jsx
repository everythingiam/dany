import Person from '../assets/person.svg';
import { Link, useNavigate } from 'react-router-dom';
import { useFormik } from 'formik';
import { formSchema } from '../utils/schemas';
import UserService from '../API/UserService';
import { useAuth } from '../hooks/useAuth';

const Registration = () => {
  const {signin} = useAuth();
  const navigate = useNavigate();

  const onSubmit = async (values, actions) => {
    const vals = { ...values };
    actions.resetForm();

    const response = await UserService.postRegistration(vals);

    if (response) {
      signin(values.nickname, () => navigate('/', { replace: true }));
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
      <img src={Person} alt="danysvg" />
      <h1>Зарегистрироваться</h1>
      <p>
        или {'\u00A0'}
        <Link to="/login">войти в аккаунт</Link>
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
              Зарегистрироваться
            </button>
          </li>
        </ul>
      </form>
    </section>
  );
};

export default Registration;

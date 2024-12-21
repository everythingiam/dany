import Person from '../assets/person.svg';
import { Link } from 'react-router-dom';
import { useFormik } from 'formik';
import { formSchema } from '../utils/schemas';

const onSubmit = () => {
  console.log('submitted');
};

const Registration = () => {
  const { values, touched, isSubmitting, handleChange, handleSubmit, errors } = useFormik({
    initialValues: {
      nickname: '',
      password: '',
    },
    validationSchema: formSchema,
    onSubmit,
  });

  return (
    <section className='login'>
      <img src={Person} alt="danysvg" />
      <h1>Зарегистрироваться</h1>
      <p>или {'\u00A0'}<Link to="/login">войти в аккаунт</Link></p>
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
              className={errors.nickname && touched.nickname ? 'input-error' : ''}
            />
            {errors.nickname && touched.nickname && <span className='error'>{errors.nickname}</span>}
          </li>
          <li>
            <input
              type="password"
              placeholder="Пароль"
              onChange={handleChange}
              id="password"
              name="password"
              value={values.password}
              className={errors.password && touched.password ? 'input-error' : ''}
            />
            {errors.password && touched.password && <span className='error'>{errors.password}</span>}

          </li>
          <li>
            <button type="submit" disabled={isSubmitting} className="btn">Войти</button>
          </li>
        </ul>
      </form>
    </section>
  )
};

export default Registration;

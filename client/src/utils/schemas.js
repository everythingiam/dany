import * as yup from 'yup';

const regex = {
  nickname: /^[a-zA-Z0-9_]+$/,
  password: /^[a-zA-Z0-9!@#$%^&*()_+=[\]{};':",.<>?/\\|`~-]+$/,
};

export const formSchema = yup.object().shape({
  nickname: yup
    .string()
    .min(3, 'Никнейм не меньше 3 символов')
    .max(20, 'Слишком длинный никнейм')
    .matches(regex.nickname, 'Только латиница, цифры и _')
    .required('Обязательно для заполнения'),
  password: yup
    .string()
    .min(3, 'Пароль не меньше 6 символов')
    .max(20, 'Слишком длинный пароль')
    .matches(regex.password, 'Только латиница, цифры и символы')
    .required('Обязательно для заполнения'),
});

export const phaseTranslations = {
  waiting: 'Ожидание',
  layout: 'Раскладка',
  discussion: 'Обсуждение',
  decision: 'Решение'
}

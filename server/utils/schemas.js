const yup = require('yup');

const regex = {
  nickname: /^[a-zA-Z0-9_]+$/,
  password: /^[a-zA-Z0-9!@#$%^&*()_+=[\]{};':",.<>?/\\|`~-]+$/,
};

const formSchema = yup.object().shape({
  nickname: yup
    .string()
    .min(3, 'Nickname not less than 3 symbols')
    .max(20, 'Nickname is too long')
    .matches(regex.nickname, 'Only latin, numbers and _')
    .required('Nickname required'),
  password: yup
    .string()
    .min(3, 'Password not less than 3 symbols')
    .max(20, 'Password is too long')
    .matches(regex.password, 'Only latin, numbers and symbols')
    .required('Password required'),
});

module.exports = formSchema;

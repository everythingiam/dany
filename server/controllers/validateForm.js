// const { formSchema } = require('../../client/src/utils/schemas');
const yup = require('yup');

const regex = {
  nickname: /^[a-zA-Z0-9_]+$/,
  password: /^[a-zA-Z0-9!@#$%^&*()_+=[\]{};':",.<>?/\\|`~-]+$/,
};

const formSchema = yup.object({
  nickname: yup
    .string()
    .min(3, 'Никнейм не меньше 3 символов')
    .max(20, 'Слишком длинный никнейм')
    .matches(regex.nickname, 'Только латиница, цифры и _')
    .required('Обязательно для заполнения'),
  password: yup
    .string()
    .min(6, 'Пароль не меньше 6 символов')
    .max(20, 'Слишком длинный пароль')
    .matches(regex.password, 'Только латиница, цифры и символы')
    .required('Обязательно для заполнения'),
});

const validateForm = (req, res) => {
  const formData = req.body;
  formSchema
    .validate(formData)
    .catch((err) => {
      res.status(422).send();
      console.log(err.errors);
    })
    .then((valid) => {
      if (valid) {
        res.status(200).send();
        console.log('form is good');
      } 
    });
};

module.exports = validateForm;

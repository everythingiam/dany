<a id="readme-top"></a>

<br />
<div align="center">
  <a href="https://github.com/othneildrew/Best-README-Template">
    <img src="readme/dany.svg" alt="Logo" width="130" height="100">
  </a>

  <h3 align="center">Дэни. Голоса в голове</h3>

  <p align="center">
    Браузерная онлайн-игра с базой данных и real-time соединением!
    <br />
    <!-- <a href="https://youtube.com"><strong>Посмотреть видео-обзор »</strong></a> -->
    <!-- <br /> -->
    <br />
    <a href="https://github.com/othneildrew/Best-README-Template">Перейти к игре</a>
    &middot;
    <a href="https://github.com/othneildrew/Best-README-Template/issues/new?labels=bug&template=bug-report---.md">Сообщить об ошибке</a>
  </p>
</div>

<!-- 
## Приколюхи

### Авторизация и смена аватара
### Карточный канвас на WebSocket -->

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Оглавление</summary>
  <ol>
    <li>
      <a href="#о-проекте">О проекте</a>
      <ul>
        <li><a href="#правила-игры">Правила игры</a></li>
        <li><a href="#стек-технологий">Стек технологий</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Установка</a>
      <ul>
        <li><a href="#запуск-фронтенда">Запуск фронтенда</a></li>
        <li><a href="#запуск-бэкенда">Запуск бэкенда</a></li>
      </ul>
    </li>
    <!-- <li>
      <a href="#database">База данных</a>
      <ul>
        <li><a href="#model">Проектирование</a></li>
        <li><a href="#logic">Логика</a></li>
      </ul>
    </li>
    <li>
      <a href="#backend">Бэкенд</a>
      <ul>
        <li><a href="#server">Сервер</a></li>
        <li><a href="#api">API</a></li>
      </ul>
    </li>
    <li>
      <a href="#frontend">Фронтенд</a>
      <ul>
        <li><a href="#front-data">Синхронизация данных</a></li>
        <li><a href="#canvas">Карточное поле</a></li>
      </ul>
    </li> -->
    <li><a href="#контакты">Контакты</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## О проекте

![Image alt](readme/gameplay.gif)

**Онлайн-игра**, выполненная в формате фуллстек-приложения, где вся игровая логика реализована на стороне базы данных и сервера.  
Игроки взаимодействуют с сервером в реальном времени через **WebSocket** и периодические **API-запросы**.


<p align="right">(<a href="#readme-top">наверх</a>)</p>



### Правила игры
Если коротко: каждый раунд активный игрок изображает слово с помощью случайных абстрактных карт, а остальные игроки пытаются угадать, что это за слово. Можно найти схожесть с «крокодилом», только это очень странный «крокодил».
<br>Дэни в данном случае является «мафией», которая путает других игроков, неправильно показывает слова и обманывает. 

<p align="right">(<a href="#readme-top">наверх</a>)</p>


### Стек технологий


* ![React](https://img.shields.io/badge/react-%2320232a.svg?style=for-the-badge&logo=react&logoColor=%2361DAFB)
* ![NodeJS](https://img.shields.io/badge/node.js-6DA55F?style=for-the-badge&logo=node.js&logoColor=white)
* ![Socket.io](https://img.shields.io/badge/Socket.io-black?style=for-the-badge&logo=socket.io&badgeColor=010101)
* ![Postgres](https://img.shields.io/badge/postgres-%23316192.svg?style=for-the-badge&logo=postgresql&logoColor=white)
* ![Bootstrap](https://img.shields.io/badge/bootstrap-%238511FA.svg?style=for-the-badge&logo=bootstrap&logoColor=white)
* ![React Router](https://img.shields.io/badge/React_Router-CA4245?style=for-the-badge&logo=react-router&logoColor=white)
* [![MobX](https://img.shields.io/badge/-MobX-orange)](https://mobx.js.org/)  
* [![axios](https://img.shields.io/badge/-axios-blue)](https://axios-http.com/)  
* [![fabric.js](https://img.shields.io/badge/-fabric.js-red)](https://fabricjs.com/)  


<p align="right">(<a href="#readme-top">наверх</a>)</p>


<!-- GETTING STARTED -->
## Установка
> [!IMPORTANT]  
> Убедитесь, что на вашем компьютере устновлен node.js и последняя версия npm:
>  <br>`npm install npm@latest -g`

Склонируйте себе репозиторий
   ```sh
   git clone https://github.com/github_username/repo_name.git
   ```
### Запуск фронтенда 


1. Перейдите в папку с клиентской частью
   ```js
   cd client
   ```   
2. Установите все зависимости
   ```sh
   npm install
   ```
3. Введите адрес API для HTTP и WS протоколов в `config.js`
   ```sh
   API_BASE_URL: "https://YOUR_API",
   WS_URL: "wss://YOUR_API"
   ```
4. Запустите комнадой
   ```sh
   npm run dev
   ```
<p align="right">(<a href="#readme-top">наверх</a>)</p>

### Запуск бэкенда 

_Чтобы развернуть проект на своём комьютере или на удалённом сервере, придётся вписать свои переменные для подключения и инициализировать логику на SQL._

1. Перейдите в папку с серверной частью
   ```js
   cd server
   ```
2. Установите все зависимости
   ```sh
   npm install
   ```
3. Создайте .env и вставьте ключи своих данных подключения к базе данных в соответствии с example.env 
   ```sh
    SERVER_PORT=2024
    CLIENT_PORT=2025
    DB_USER=user
    DB_PASSWORD=*****
    ...
   ```
    > [!IMPORTANT]  
    > едитесь, что у вас установлен PostgreSQL (или другя СУБД).
    >  <br>`psql --version`
4. Создайте базу данных
   ```sh
   createdb my_database
   ```
5. Импортируйте структуру таблиц из файла database/init.sql
   ```sh
   psql -U your_user -d my_database -f database/init.sql
    ```
6. Запустите сервер комнадой
   ```sh
   npm run dev
   ```

<p align="right">(<a href="#readme-top">наверх</a>)</p>




<!-- CONTRIBUTING -->
## Контрибьюшен

Любой контрибьюшен **очень ценен**.

Если у вас есть предложения того, как сделать этот проект лучше, то сделайте fork репозитория и pull request. Не забудьте добавить звёздочку! Спасибо!

1. Сделайте fork проекта
2. Создайте свою ветку (`git checkout -b feature/AmazingFeature`)
3. Закоммитьте изменения (`git commit -m 'Add some AmazingFeature'`)
4. Отправьте их в свою ветку (`git push origin feature/AmazingFeature`)
5. Отправьте Pull Request

<p align="right">(<a href="#readme-top">наверх</a>)</p>




<!-- CONTACT -->
## Контакты

Михайлова Алина - [t.me/a_li_nus](https://t.me/a_li_nus) - alina.mikhaylova.03@mail.ru

Ссылка проекта: [https://github.com/everythingiam/dany](https://github.com/everythingiam/dany)

<p align="right">(<a href="#readme-top">наверх</a>)</p>





<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/othneildrew/Best-README-Template.svg?style=for-the-badge
[contributors-url]: https://github.com/othneildrew/Best-README-Template/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/othneildrew/Best-README-Template.svg?style=for-the-badge
[forks-url]: https://github.com/othneildrew/Best-README-Template/network/members
[stars-shield]: https://img.shields.io/github/stars/othneildrew/Best-README-Template.svg?style=for-the-badge
[stars-url]: https://github.com/othneildrew/Best-README-Template/stargazers
[issues-shield]: https://img.shields.io/github/issues/othneildrew/Best-README-Template.svg?style=for-the-badge
[issues-url]: https://github.com/othneildrew/Best-README-Template/issues
[license-shield]: https://img.shields.io/github/license/othneildrew/Best-README-Template.svg?style=for-the-badge
[license-url]: https://github.com/othneildrew/Best-README-Template/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/othneildrew
[product-screenshot]: images/screenshot.png
[Next.js]: https://img.shields.io/badge/next.js-000000?style=for-the-badge&logo=nextdotjs&logoColor=white
[Next-url]: https://nextjs.org/
[React.js]: https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB
[React-url]: https://reactjs.org/
[Vue.js]: https://img.shields.io/badge/Vue.js-35495E?style=for-the-badge&logo=vuedotjs&logoColor=4FC08D
[Vue-url]: https://vuejs.org/
[Angular.io]: https://img.shields.io/badge/Angular-DD0031?style=for-the-badge&logo=angular&logoColor=white
[Angular-url]: https://angular.io/
[Svelte.dev]: https://img.shields.io/badge/Svelte-4A4A55?style=for-the-badge&logo=svelte&logoColor=FF3E00
[Svelte-url]: https://svelte.dev/
[Laravel.com]: https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white
[Laravel-url]: https://laravel.com
[Bootstrap.com]: https://img.shields.io/badge/Bootstrap-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white
[Bootstrap-url]: https://getbootstrap.com
[JQuery.com]: https://img.shields.io/badge/jQuery-0769AD?style=for-the-badge&logo=jquery&logoColor=white
[JQuery-url]: https://jquery.com 

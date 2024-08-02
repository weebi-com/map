# README

1. install ruby v3.1.2 & rails 7.1.3
    - https://gorails.com/setup/
    - install node 20 using nvm  
      - follow https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating
      - nvm install 20
      - nvm use 20
2. install postgres
4. bundle install
5. yarn install à faire à la racine
6. rake db:create
7. rake db:migrate
8. npm install -g foreman
9. yarn global add foreman
10. run : nf start -f Procfile.dev
11. (better than rails server)


Create a user
```
rails c
```
```
User.create(email: "weebi@weebi.com", password: "weebi@weebi.com", password_confirmation: "weebi@weebi.com")
```
- Login with the user created with the url : http://localhost:5000/login

useful tools
- macos : Postgres (app)
- macos : pgAdmin
https://classic.yarnpkg.com/en/package/foreman

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version
* System dependencies
* Configuration
* Database creation
* Database initialization
* How to run the test suite
* Services (job queues, cache servers, search engines, etc.)
* Deployment instructions
* ...

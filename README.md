![https://commons.m.wikimedia.org/wiki/File:Georeferenced_observation.png](icon.png)

> Boutique map
Application Ruby on Rails avec PostgreSQL et Bootstrap
Ce document explique les étapes nécessaires pour installer, configurer et lancer votre application Ruby on Rails.

## Prérequis
- **Ruby** : v3.1.2
- **Rails** : v7.1.3
- **PostgreSQL** : Installation nécessaire pour la base de données
- **Node.js** : v20.x (installation via NVM recommandée)
- **Bootstrap** : pour la mise en forme et l'interface utilisateur

### windows
1. **Installer Ruby et Rails** 
all in one : 
- https://railsinstaller.dev/

manually : 
- https://www.nethad.io/2021/12/19/rails70-on-windows-without-wsl/

Check whether winget is installed, if not install or update App Installer from the Microsoft Store from here
Open PowerShell and enter: winget install OpenJS.NodeJS.LTS; winget install Yarn.Yarn; winget install Git.Git; winget install RubyInstallerTeam.RubyWithDevKit
Close Powershell, open “Start Command Prompt with Ruby”, enter: ridk install 3
   - ruby https://rubyinstaller.org/
Close prompt, open a PowerShell, enter: gem install sqlite3; gem install rails --version "~> 7.0" --no-doc; 
bundle install


2. **Installer Node.js**  
choco install nodejs-lts --version="20.16.0"
Utilisez NVM pour gérer les versions de Node.js :  
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
```
Puis installez Node.js v20.x :  
```bash
nvm install 20
nvm use 20
```

3. **Installer PostgreSQL**  
Installez PostgreSQL selon votre système d'exploitation. 

4. **Installer les dépendances de l'application**  
À la racine de votre projet, exécutez les commandes suivantes :  
   ```bash
   bundle install
   yarn install
   ```

5. **Configurer la base de données**  
   Créez et migrez la base de données :  
   ```bash
   rails db:create
   rails db:migrate
   ```
- bundle exec rails server

6. **Installer Foreman**  
   Foreman permet de gérer les processus de développement. Installez-le avec les commandes suivantes :  
   ```bash
   npm install -g foreman
   yarn global add foreman
   ```

7. **Lancer l'application**  
   Pour lancer l'application, utilisez la commande foreman suivante  :  
      NB : Peut avoir besoin de ci-dessous sous windows :
      Set-ExecutionPolicy Unrestricted

   ```bash
   nf start -f Procfile.dev --env /dev/null
   ```
   Cette commande est une alternative à `rails server`, offrant une meilleure gestion des processus.

## Créer un utilisateur administrateur

1. Ouvrez la console Rails :  
   ```bash
   rails c
   ```

2. Créez un utilisateur :  
   ```ruby
   User.create(email: "boutique@boutique.com", password: "boutique@boutique.com", password_confirmation: "boutique@boutique.com")
   ```

3. Connectez-vous avec l'utilisateur créé à l'URL suivante :  
   [http://localhost:5000/login](http://localhost:5000/login)

## Génération des seeds
Vous pouvez peupler votre base de données avec des catégories et des entreprises en exécutant les seeds. Ajoutez le code suivant à votre fichier `db/seeds.rb` :

```ruby
# Seed categories
categories = []
10.times do |i|
  code = Faker::Number.unique.number(digits: 4).to_s
  description = Faker::Company.industry
  categories << Category.create!(code: code, description: description)
end

# Seed entreprises
1000.times do
  category = categories.sample
  Entreprise.create!(
    niu: Faker::Number.unique.number(digits: 10).to_s,
    forme: Faker::Company.type,
    raison_sociale_rgpd: Faker::Company.name,
    sigle: Faker::Company.suffix,
    activite: Faker::Company.industry,
    region: Faker::Address.state,
    departement: Faker::Address.city,
    ville: Faker::Number.number(digits: 4),
    commune: Faker::Address.community,
    quartier: Faker::Address.street_name,
    lieux_dit: Faker::Address.street_address,
    boite_postale: Faker::Address.postcode,
    npc: Faker::Number.number(digits: 3),
    npc_intitule: Faker::Lorem.word,
    isic_refined: category.code.to_i,
    isic_1_dig: category.code.to_i,
    isic_2_dig: category.code.to_i,
    isic_3_dig: category.code,
    isic_4_dig: category.code,
    isic_intitule: category.description,
    latitude: rand(2.0..13.0),  # Latitudes spécifiques au Cameroun
    longitude: rand(8.0..16.0),  # Longitudes spécifiques au Cameroun
    created_at: Time.now,
    updated_at: Time.now
  )
end

puts "Seed completed successfully!"
```

Pour exécuter les seeds, utilisez la commande suivante :
```bash
rails db:seed
```

## Outils utiles

- **PostgreSQL pour macOS** : [Postgres.app](https://postgresapp.com/)
- **Interface utilisateur pour PostgreSQL** : [pgAdmin](https://www.pgadmin.org/)

## Documentation supplémentaire

Ce README couvre les étapes essentielles pour configurer l'application. N'hésitez pas à le personnaliser en fonction de vos besoins spécifiques. 
Pour plus d'informations sur des aspects spécifiques comme les tests, la configuration avancée, ou le déploiement, vous pouvez inclure des sections supplémentaires comme :


- Version de Ruby utilisée
- Dépendances système
- Configuration spécifique
- Instructions de déploiement

---

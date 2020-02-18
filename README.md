Pangolin 
###

run 
```
rails db:create db:migrate db:seed
```

in pangolin-payments

```
sequelize db:create && sequelize db:migrate
npm run dev
```

you will have to run and setup your monero daemon for XMR support on the pangolin-payment side.

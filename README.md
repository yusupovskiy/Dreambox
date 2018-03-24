TBIS
====

## About the project 
#### The Big Information System is the project for organizations to manage their data

## Facilities
* Full functionality of authentication system like email confirmation and so on (thanks [Devise gem](https://github.com/plataformatec/devise))
* [User Roles](https://github.com/kofon95/TBIS/blob/master/app/models/user.rb#L17)
* Company owner can create companies, affiliates (for that company), and clients (which are customer for concrete company)
* Any client can become high-grade user; if such user exists (in other company) they merge

## What is coming soon
* Courses with dynamic fields
* Tariffs
* Subscriptions
* Elastic Search or Sphinx

## Some example routes
* `/companies` - list of companies of current user
* `/companies/1/affiliates` - list of affiliates each of which belongs to company with id 1
* `/companies/1/clients` - similar to route above but for clients

## Supported databases
* Postgres
* MySQL _(at risk of being unsupported)_

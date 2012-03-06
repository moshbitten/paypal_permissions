# PayPal Permissions

## Assumptions

You have the ActiveMerchant gem installed.

## Caveats

Earlier this morning, this README file contained the following content:

> Nothing to see here yet. A work in progress.

This code is currently released only to facilitate my very own testing. But apparently, PayPal directed at least one Ruby developer here, so I'm trying to catch up with demand. :)

Bear in mind that the resource generator creates a number of fields in the database migration that are undoubtedly superfluous in some cases, and perhaps inadequate in others. If you're looking for a full audit trail by way of database entries for every permissions interaction, you may have to rely on your logs, not on the database. Even so, the generated schema should get the job done.

## Install

`rails generate paypal_permissions:install`

Running the install generator will:

- update your config/environments/{development,test,production}.rb files. You must edit these files with your PayPal credentials.
- create a currently useless config/initializers/paypal_permissions.rb initializer.
- create a currently useless config/locales/paypal_permissions.en.yml local file.


## Optionally generate resources

`rails generate paypal_permissions <new or existing resource name>`

This generator will:

- create a migration which updates the table for an existing model or creates a new table along with a new model. ActiveRecord is the only supported orm.
- create a controller.
- insert routes into config/routes.rb


## Rolling your own

### Routes

`match 'paypal_perms/request_permissions_callback' => 'paypal_perms#request_permissions_callback',
    :via => [ :get ], :as => :paypal_perms_request_permissions_callback`
`resources :paypal_perms, :only => [ :index, :new, :create, :show ]`

### Models, migrations, and controllers

See the `examples` directory.

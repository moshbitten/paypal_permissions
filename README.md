# PayPal Permissions

## Dependencies

Rails 3.1 or later.

The PayPal Permissions gem installs ActiveMerchant if it's not already in place.
PayPal Permissions is known to work with ActiveMerchant 1.21.


## Install

In your Gemfile:

`gem paypal_permissions`

After installing the gem:

`rails generate paypal_permissions:install`

Running the install generator will:

- update your config/environments/{development,test,production}.rb files. You must edit these files with your PayPal credentials.
- create an initializer in config/initializers/paypal_permissions.rb


## Optionally generate resources

`rails generate paypal_permissions <new or existing resource name>`

This generator will:

- create a migration which updates the table for an existing model or creates a new table along with a new model. ActiveRecord is the only supported orm.
- create a controller. For help, take a look at the example controller in `examples/app/controllers/merchants_controller.rb`.
- insert routes into config/routes.rb. Make sure that the request_permissions_callback route is inserted before the resources routes.

For example, if you plan to query PayPal using getBasicPersonalData and getAdvancedPersonalData, you might generate a merchant model like:

`rails generate paypal_permissions merchant email:string first_name:string last_name:string full_name:string country:string payer_id:string street1:string street2:string city:string state:string postal_code_string phone:string birth_date:string`
`bundle exec rake db:migrate`

## Rolling your own resources

### Routes

You must provide a callback route for PayPal. Again, for help, see `examples/app/controllers/merchants_controller.rb`.

`match 'paypal_perms/request_permissions_callback' => 'paypal_perms#request_permissions_callback',
    :via => [ :get ], :as => :paypal_perms_request_permissions_callback`
`resources :paypal_perms, :only => [ :index, :new, :create, :show ]`

### Models, migrations, and controllers

The resources generator will populate your model and migration, as well as create an empty controller.

For more help, see the `examples` directory.

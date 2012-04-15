# PayPal Permissions

## Assumptions

You have the ActiveMerchant gem installed.

`rails generate paypal_permissions:install`

Running the install generator will:

- update your config/environments/{development,test,production}.rb files. You must edit these files with your PayPal credentials.
<!-- - create a currently useless config/initializers/paypal_permissions.rb initializer. -->
<!-- - create a currently useless config/locales/paypal_permissions.en.yml local file. -->


## Optionally generate resources

`rails generate paypal_permissions <new or existing resource name>`

This generator will:

- create a migration which updates the table for an existing model or creates a new table along with a new model. ActiveRecord is the only supported orm.
- create a controller.
- insert routes into config/routes.rb. Make sure that the request_permissions_callback route is inserted before the resources routes.

For example, if you plan to query PayPal using getBasicPersonalData and getAdvancedPersonalData, you might generate a merchant model like:

`rails generate paypal_permissions merchant email:string first_name:string last_name:string full_name:string country:string payer_id:string street1:string street2:string city:string state:string postal_code_string phone:string birth_date:string`
`bundle exec rake db:migrate`

## Rolling your own

### Routes

`match 'paypal_perms/request_permissions_callback' => 'paypal_perms#request_permissions_callback',
    :via => [ :get ], :as => :paypal_perms_request_permissions_callback`
`resources :paypal_perms, :only => [ :index, :new, :create, :show ]`

### Models, migrations, and controllers

See the `examples` directory.

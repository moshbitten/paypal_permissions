require 'uri'

class PaypalPermsController < ApplicationController
  def index
    render :text => "paypal perms"
  end

  def new
    school_id = session[:school_id]
    @paypal_perms = PaypalPerm.new(:school_id => school_id)
  end

  def create
    school = School.find_by_id params[:paypal_perm][:school_id]
    if school
      paypal_perms = PaypalPerm.new(:school => school)
      if paypal_perms.save
        g = ::PAYPAL_PERMISSIONS_GATEWAY
        callback_url = paypal_perms_request_permissions_callback_url
        # Make @paypal_response an instance variable just to facilitate testing
        @paypal_response = g.request_permissions URI.encode(callback_url), 'DIRECT_PAYMENT'
        if @paypal_response[:ack] == 'Success'
          token = @paypal_response[:token]
          if token.present?
            paypal_perms.update_attribute :request_permissions_request_token, token
            url = g.redirect_user_to_paypal_url(token)
            redirect_to url
            return
          else
            # this should never happen, hence, it's pretty much unrecoverable
            raise
          end
        else
          message = @paypal_response[:errors][0][:message]  # TODO: need a method to find error messages or display a generic message
          flash[:error] = message
          redirect_to new_paypal_perm_path
        end
      else
        message = "unable to create paypal_perms object"
        flash[:error] = message
        redirect_to new_paypal_perm_path
      end
    else
      message = "can't find that school"
      flash[:error] = message
      redirect_to new_paypal_perm_path
    end
  end

  # Really, request_permissions_callback should do all this.
  def update
    paypal_perms = PaypalPerm.find_by_request_permissions_request_token params[:request_token]
    if paypal_perms
      g = ::PAYPAL_PERMISSIONS_GATEWAY
      # Make @paypal_response an instance variable just to facilitate testing
      @paypal_response = g.get_access_token paypal_perms.request_permissions_request_token, paypal_perms.request_permissions_callback_verifier
      if @paypal_response[:ack] == 'Success'
        paypal_perms.update_attributes({
          :get_access_token_access_token => @paypal_response[:token],
          :get_access_token_verifier => @paypal_response[:tokenSecret],
        })
        render :text => 'thanks for the access token'
      else
        flash[:error] = @paypal_response[:errors][0][:message]  # TODO: need a method to find error messages or display a generic message
        redirect_to new_paypal_perm_path
      end
    else
      render :text => "that permission doesn't exist"
    end
  end

  def show
    if params[:id] == 'request_permissions_callback'
      render :text => "We're sorry to see that you haven't given us permission to execute payment transactions."
    else
      respond_with PaypalPerm.find_by_id(params[:id])
    end
  end

  def request_permissions_callback
    perms = PaypalPerm.find_by_request_permissions_request_token params[:request_token]
    if perms
      if perms.valid?
        if perms.update_attribute :request_permissions_callback_verifier, params[:verification_code]
          update
        else
          render :text => "thanks for the permission, but i've got problems"
        end
      else
        render :text => "perms wasn't valid: #{perms.errors}"
      end
    else
      if Rails.env.development? || Rails.env.test?
        perms = PaypalPerm.create({
          :school_id => session[:school_id],
          :request_permissions_request_token => params[:request_token],
          :request_permissions_callback_verifier => params[:verification_code],
        })
        if perms
          render :text => "that permission doesn't exist, but to facilitate testing i created it"
        else
          render :text => "that permission doesn't exist, and i couldn't create it, not even for testing"
        end
      else
        render :text => "perms isn't valid: #{perms.errors.inspect}"
      end
    end
  end
end

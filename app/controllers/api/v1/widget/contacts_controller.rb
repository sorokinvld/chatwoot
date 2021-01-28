class Api::V1::Widget::ContactsController < Api::V1::Widget::BaseController
  def update
    process_hmac
    contact_identify_action = ContactIdentifyAction.new(
      contact: @contact,
      params: permitted_params.to_h.deep_symbolize_keys
    )
    render json: contact_identify_action.perform
  end

  private

  def process_hmac
    return if params[:identifier_hash].blank?
    raise StandardError, 'HMAC failed: Invalid Identifier Hash Provided' unless valid_hmac?

    @contact_inbox.update(hmac_verified: true)
  end

  def valid_hmac?
    params[:identifier_hash] == OpenSSL::HMAC.hexdigest(
      'sha256',
      @web_widget.hmac_token,
      params[:identifier].to_s
    )
  end

  def permitted_params
    params.permit(:website_token, :identifier, :identifier_hash, :email, :name, :avatar_url, custom_attributes: {})
  end
end

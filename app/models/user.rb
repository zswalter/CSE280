class User < ActiveRecord::Base
 
  attr_accessible :address, :city, :email, :firstname, :lastname, :password, :postalcode,
   :state, :password_confirmation, :STATE_CODE, :phonenumber
  
  email_regex = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i
  password_regex = /^(?=.*\d)(?=.*[a-zA-Z]).{4,16}$/
  phone_regex = /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/
  
  validates_presence_of :state, :message => 'Please select a state.'
  validates_presence_of :address, :message => 'Please provide an address.'
  validates_presence_of :city, :message => 'Please provide a city.'
  validates_presence_of :firstname, :message => 'Please provide a first name.'
  validates_presence_of :lastname, :message => 'Please provide a last name.'
  validates_format_of :postalcode, :with => /\d{5}/, :message => 'Please provide a vaild zip code.'
  validates_format_of :password, :if => :password_present?,:with => password_regex, :message => 'Password needs to have one character and one digit'
  validates_uniqueness_of :email, :message => 'E-mail has is already in use.'
  validates_format_of :email, :with => email_regex, :message => 'E-mail is invalid.'
  validates_format_of :phonenumber, :with => phone_regex, :message => 'Phone number needs to be in the format of (XXX)-XXX-XXXX'
  
  acts_as_authentic do |config|
    config.login_field = :email
    config.validate_email_field = false
    config.validate_login_field = false
    config.merge_validates_length_of_password_confirmation_field_options  :allow_blank => true
    config.merge_validates_confirmation_of_password_field_options :message => "Password and confirmation are mismatched."
    config.merge_validates_length_of_password_field_options :message => "Password should be a minimum of 4 charaters long."
  end
  
  STATE_CODE = ['AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY',
    'LA', 'ME', 'MD', 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 'OH', 'OK',
     'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY']
  
  
  def password_present?
  !password.nil?
  end
  
end

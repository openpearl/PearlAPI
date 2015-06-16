class Api::V1::User < ActiveRecord::Base
  def listusers
    `curl https://api.truevault.com/v1/users -X GET -u 0dd527f0-cc45-4a11-b548-9d0a93f62c71:`
    
  end
end

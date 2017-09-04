module RedmineQyWechat
  module Patches
    module AccountControllerPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          # defind a globle var for backurl
          alias_method_chain :login, :login_dingtalk
          alias_method_chain :successful_authentication, :login_dingtalk
        end
      end
    
      module InstanceMethods
        def login_with_login_dingtalk
          code = params[:code]
          state = params[:state]
          # 如果是钉钉登录回调
          if state == "DingTalkSTATE"
            appid = Setting["plugin_redmine_work_wechat"]["dingtalk_login_appid"]
            appsecret = Setting["plugin_redmine_work_wechat"]["dingtalk_login_appsecret"]
            redirect_url = Setting["plugin_redmine_work_wechat"]["dingtalk_login_redirect"]
            
            if (appid.blank? || appsecret.blank? || redirect_url.blank?)
              return
            end
            
            begin
            
            uri = URI.parse("https://oapi.dingtalk.com/sns/gettoken?appid=#{appid}&appsecret=#{appsecret}")
          
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            request_dd = Net::HTTP::Get.new(uri.request_uri)  
          
            response = http.request(request_dd)
              
            # 获得token
            token = JSON.parse(response.body)["access_token"]
          
            uri = URI.parse("https://oapi.dingtalk.com/sns/get_persistent_code?access_token=#{token}&tmp_auth_code=#{code}")
            http = Net::HTTP.new(uri.host,uri.port)
            http.use_ssl = true
          
            data = {
              "tmp_auth_code":  "#{code}"
            }.to_json
          
            request_dd = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
          
            request_dd.body = data
          
            response = http.request(request_dd)
          
          
            # 获得openid和永久授权码
            openid = JSON.parse(response.body)["openid"]
            persistent_code = JSON.parse(response.body)["persistent_code"]
          
            uri = URI.parse("https://oapi.dingtalk.com/sns/get_sns_token?access_token=#{token}")
          
            http = Net::HTTP.new(uri.host,uri.port)
            http.use_ssl = true
          
            data = {
              "openid": "#{openid}",
              "persistent_code": "#{persistent_code}"
            }.to_json
          
            request_dd = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
          
            request_dd.body = data
            response = http.request(request_dd)
          
            # 获得sns_token
            sns_token = JSON.parse(response.body)["sns_token"]
          
            uri = URI.parse("https://oapi.dingtalk.com/sns/getuserinfo?sns_token=#{sns_token}")
          
            http = Net::HTTP.new(uri.host,uri.port)
            http.use_ssl = true
            request_dd = Net::HTTP::Get.new(uri.request_uri)  
          
            response = http.request(request_dd)
              
            # 获得用户id
            $dingid = JSON.parse(response.body)["user_info"]["dingId"]
            
            rescue
            end
            
            user = User.find_by dingtalk_dingid: $dingid
            if !user.blank?
             if user.active?
                successful_authentication(user)
              else
                handle_inactive_user(user)
              end
            end
            return
          end
          
          login_without_login_dingtalk
        end
      end
      
      def successful_authentication_with_login_dingtalk(user)
        if !$dingid.blank?
          # 更新当前的dingid
          user.update_attributes(:dingtalk_dingid=>$dingid) 
        end
        successful_authentication_without_login_dingtalk user
      end
    end
  end
end

unless AccountController.included_modules.include?(RedmineQyWechat::Patches::AccountControllerPatch)
  AccountController.send(:include, RedmineQyWechat::Patches::AccountControllerPatch)
end
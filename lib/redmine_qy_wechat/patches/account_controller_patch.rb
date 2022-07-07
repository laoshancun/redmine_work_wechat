module RedmineQyWechat
  module Patches
    module AccountControllerPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          # defind a globle var for backurl
          # 适配4.0 
          alias_method :login_without_qrcode, :login
          alias_method :login, :login_with_qrcode
          alias_method :successful_authentication_without_login_dingtalk, :successful_authentication
          alias_method :successful_authentication, :successful_authentication_with_login_dingtalk
        end
      end
    
      module InstanceMethods

        def login_with_qrcode
          login_type = params[:login_type]

          case login_type
          when "1"
            login_with_login_wechat
          when "2"
            login_with_login_dingtalk
          else
            password_login_forbbid = Setting["plugin_redmine_work_wechat"]["login_password_forbbid"] != "0"
            is_same_psk = Setting["plugin_redmine_work_wechat"]["login_password_psk"] == params[:psk]
            # allow password login with psk when password login forbbiden.
            unless password_login_forbbid
              login_without_qrcode  
            else
              flash[:error] = l(:flash_password_login_forbbid) if request.method() == "POST" && !is_same_psk
            end
          end
        end

        def login_with_login_wechat
          code = params[:code]
          state = params[:state]
          # 如果是企业微信登录回调
          if state == "CORPWECHATSTATE"
            corpid = Setting["plugin_redmine_work_wechat"]["wechat_login_corpid"]
            appsecret = Setting["plugin_redmine_work_wechat"]["wechat_login_appsecret"]
          
            if (corpid.blank? || appsecret.blank?)
              return
            end
          
            begin
            $userid = nil # 置空
            # 获取access token
            uri = URI.parse("https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=#{corpid}&corpsecret=#{appsecret}")
        
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            request_dd = Net::HTTP::Get.new(uri.request_uri)  
        
            response = http.request(request_dd)
            
            # 获取访问用户身份
            token = JSON.parse(response.body)["access_token"]
        
            uri = URI.parse("https://qyapi.weixin.qq.com/cgi-bin/user/getuserinfo?access_token=#{token}&code=#{code}")
            http = Net::HTTP.new(uri.host,uri.port)
            http.use_ssl = true
        
          
            request_dd = Net::HTTP::Get.new(uri.request_uri)
        
            response = http.request(request_dd)
        
            # 获得userid
            $userid = JSON.parse(response.body)["UserId"]

            rescue
              flash[:notice] = l(:flash_wechat_bind)
              return
            end
          
            user = User.find_by corp_wechat_account_number: $userid unless $userid.blank?
            
            unless user.blank?
              if user.active?
                successful_authentication(user)
              else
                handle_inactive_user(user)
              end
            else
              unless $userid.blank?
                flash[:notice] = l(:flash_wechat_bind)
              end
            end
            return
          end
        end


        def login_with_login_dingtalk
          auth_code = params[:auth_code]
          if auth_code.blank?
            code = params[:code]
            state = params[:state]
            # 如果是钉钉登录回k调
            if state == "DingTalkSTATE"
              appid = Setting["plugin_redmine_work_wechat"]["dingtalk_login_appid"]
              appsecret = Setting["plugin_redmine_work_wechat"]["dingtalk_login_appsecret"]
              redirect_url = Setting["plugin_redmine_work_wechat"]["dingtalk_login_redirect"]
            
              if (appid.blank? || appsecret.blank? || redirect_url.blank?)
                return
              end
            
              begin
              $dingid = nil # 置空
          
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
                tmp_auth_code:  "#{code}"
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
                openid: "#{openid}",
                persistent_code: "#{persistent_code}"
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
                flash[:notice] = l(:flash_dingtalk_bind)
                return
              end
            
              user = User.find_by dingtalk_dingid: $dingid unless $dingid.blank?
              
              unless user.blank?
                if user.active?
                  successful_authentication(user)
                else
                  handle_inactive_user(user)
                end
              else
                unless $dingid.blank?
                  flash[:notice] = l(:flash_dingtalk_bind)
                end
              end
              return
            end
          else  # 处理钉钉免登
            corpid = Setting["plugin_redmine_work_wechat"]["dingtalk_corp_id"]
            corpsecret = Setting["plugin_redmine_work_wechat"]["dingtalk_corp_secret"]
            if (corpid.blank? || corpsecret.blank?)
              flash[:error] = l(:flash_dingtalk_autologin_error)
              redirect_to home_url
              return
            end
            
            begin
              uri = URI.parse("https://oapi.dingtalk.com/gettoken?corpid=#{corpid}&corpsecret=#{corpsecret}")
              http = Net::HTTP.new(uri.host, uri.port)
              http.use_ssl = true
              request = Net::HTTP::Get.new(uri.request_uri)  
              response = http.request(request)
          
              # 获得token
              token = JSON.parse(response.body)["access_token"]          
              
              uri = URI.parse("https://oapi.dingtalk.com/user/getuserinfo?access_token=#{token}&code=#{auth_code}")
              http = Net::HTTP.new(uri.host, uri.port)
              http.use_ssl = true
              request = Net::HTTP::Get.new(uri.request_uri)  
              response = http.request(request)
          
              # 获得token
              
              err_code = JSON.parse(response.body)["errcode"]          
              if err_code != 0
                flash[:error] = l(:flash_dingtalk_autologin_error)
                redirect_to home_url
                return
              end
              
              dingtalk_user_id = JSON.parse(response.body)["userid"]          
               
            rescue
              flash[:error] = l(:flash_dingtalk_autologin_error)
              redirect_to home_url
              return
            end
            user = User.find_by dingtalk_account_number: dingtalk_user_id unless dingtalk_user_id.blank?
            unless user.blank?
              if user.active?
                successful_authentication(user)
              else
                handle_inactive_user(user)
              end
            else
              flash[:error] = l(:flash_dingtalk_autologin_error)
              redirect_to home_url
            end
            return
          end
        end
      end
      
      def successful_authentication_with_login_dingtalk(user)
        if !$dingid.blank?
          # 更新当前的dingid
          user.update_attributes(:dingtalk_dingid=>$dingid)
          $dingid = nil # 置空
        end
        successful_authentication_without_login_dingtalk user
      end
    end
  end
end

unless AccountController.included_modules.include?(RedmineQyWechat::Patches::AccountControllerPatch)
  AccountController.send(:include, RedmineQyWechat::Patches::AccountControllerPatch)
end
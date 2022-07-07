module RedmineQyWechat
    module Patches
        module CorpWechatsJournalsPatch
            extend ActiveSupport::Concern
            # 当创建journal时发送消息
            require 'net/http'
            require 'net/https'
          
            included do
            after_create :send_messages_after_create_journal
            end
          
          # 用企业微信发送 
          def send_by_wechat(send_people_wx)
               #填写确认并应用的企业ID
              corpid = Setting["plugin_redmine_work_wechat"]["wechat_corp_id"]
              #填写确认并应用的应用Secret
              corpsecret = Setting["plugin_redmine_work_wechat"]["wechat_app_secret"]
              
              app_id = Setting["plugin_redmine_work_wechat"]["wechat_app_id"]
                    
              if corpid.blank? || corpsecret.blank? || app_id.blank?
                return
              end
              @group_client = QyWechatApi::Client.new(corpid, corpsecret)
              # 为了确保用户输入的corpid, corpsecret是准确的，请务必执行：
                
              if @group_client.blank?
                return
              end
          
              
              # 改成异常捕捉，避免is_valid?方法本身的出错
              begin
          if @group_client.is_valid?
            #options = {access_token: "access_token"}
            # redis_key 也可定制
            #group_client = QyWechatApi::Client.new(corpid, corpsecret, options)
            #issue
            #填写确认并应用的应用AgentId
        
            @group_client.message.send_text(send_people_wx, "", "", app_id,
            "#{l(:msg_focus)} <a href=\'" + Setting.protocol + "://" + Setting.host_name + "/issues/#{@issue.id}\'>#{@issue.tracker} ##{@issue.id}: #{@issue.subject}</a> #{l(:msg_by)} <a href=\'javascript:void(0);\'>@#{@issue.journals.last.user}</a> #{l(:msg_updated)}\n#{@issue.journals.last.notes}")
          end
        rescue => e
    
        logger.error(
        "An error occured while send message for #{@issue.id}\n" \
            "Exception was: #{e.message}"
        ) if logger
    
        end 
          end
              
          # 用钉钉发送 
          def send_by_dingtalk(send_people_dd)
            #填写确认并应用的企业ID
            corpid = Setting["plugin_redmine_work_wechat"]["dingtalk_corp_id"]
            #填写确认并应用的应用Secret
            corpsecret = Setting["plugin_redmine_work_wechat"]["dingtalk_corp_secret"]
              
            appid = Setting["plugin_redmine_work_wechat"]["dingtalk_app_id"]
                    
            if corpid.blank? || corpsecret.blank? || appid.blank?
              return
            end
            uri = URI.parse("https://oapi.dingtalk.com/gettoken?corpid=#{corpid}&corpsecret=#{corpsecret}")
            # 改成异常捕捉，避免is_valid?方法本身的出错
            begin
              http = Net::HTTP.new(uri.host, uri.port)
              http.use_ssl = true
              request = Net::HTTP::Get.new(uri.request_uri)  
                    
              response = http.request(request)
                  
              # 获得token
              token = JSON.parse(response.body)["access_token"]
            
              issue_url =  Setting.protocol + "://" + Setting.host_name + "/issues/#{@issue.id}"
              issue_title = @issue.project.name
              
              issue_text = "#{@issue.tracker} ##{@issue.id}: #{@issue.subject} #{l(:msg_by)} #{@issue.journals.last.user} #{l(:msg_updated)}(##{@issue.journals.size})"
            
              data = {
                touser: send_people_dd,
                toparty: "",
                agentid: "#{appid}",
                msgtype: "link",
                link: {
                  messageUrl: issue_url,
                  picUrl: "",
                  title: issue_title,
                  text: issue_text
                }
              }.to_json
                
                
              url = URI.parse("https://oapi.dingtalk.com/message/send?access_token=#{token}")  
              http = Net::HTTP.new(url.host,url.port)
              http.use_ssl = true
              
              #req = Net::HTTP::Post.new(url.path, initheader = {'Content-Type' =>'application/json'})
              req = Net::HTTP::Post.new(url.request_uri, 'Content-Type' => 'application/json')
                  
              req.body = data
              res = http.request(req)
            rescue
            end
          end

          def send_messages_after_create_journal
            # firstly ignore the anonymouse to avoid notification bug
            # 拷贝app_notifications_journals_patch.rb
            if user.id == 2
              return
            end
            issue = journalized.reload
            to_users = notified_users
            cc_users = notified_watchers - to_users
            notify_users = to_users + cc_users
            
            
            issue = journalized
            @issue = issue
            
            if notify?
              # 需要接受微信和钉钉的用户ID集合
              send_people_wx = ""
              send_people_dd = ""
              # 用@issue自带的方法获取需要通知的用户列表
                    
              notify_users.each do |user|
                unless user.corp_wechat_account_number.blank?
                  send_people_wx.concat(user.corp_wechat_account_number).concat("|")
                end
                unless user.dingtalk_account_number.blank?
                  send_people_dd.concat(user.dingtalk_account_number).concat("|")
                end
              end
              

              # # 作者
              # unless @issue.author_id.nil?
              #   unless User.where(:id => @issue.author_id).first.corp_wechat_account_number.blank?
              #     send_people_wx.concat(User.where(:id => @issue.author_id).first.corp_wechat_account_number).concat("|")
              #   end
              # end
              
              # # 指派者
              # unless @issue.assigned_to_id.nil?
              #   unless User.where(:id => @issue.assigned_to_id).first.corp_wechat_account_number.blank?
              #     send_people_wx.concat(User.where(:id => @issue.assigned_to_id).first.corp_wechat_account_number).concat("|")
              #   end
              # end

              # # 关注者
              # @issue.watcher_users.each do |information|
              #   unless User.where(:id => information.id).first.corp_wechat_account_number.blank?
              #     send_people_wx.concat(User.where(:id => information.id).first.corp_wechat_account_number).concat("|")
              #   end
              # end
              
              if !send_people_wx.blank?
                send_by_wechat send_people_wx
              end
              
              # 以下是钉钉的处理
              # 作者
              # unless @issue.author_id.nil?
              #   unless User.where(:id => @issue.author_id).first.dingtalk_account_number.blank?
              #     send_people_dd.concat(User.where(:id => @issue.author_id).first.dingtalk_account_number).concat("|")
              #   end
              # end
              
              # # 指派者
              # unless @issue.assigned_to_id.nil?
              #   unless User.where(:id => @issue.assigned_to_id).first.dingtalk_account_number.blank?
              #     send_people_dd.concat(User.where(:id => @issue.assigned_to_id).first.dingtalk_account_number).concat("|")
              #   end
              # end

              # # 关注者
              # @issue.watcher_users.each do |information|
              #   unless User.where(:id => information.id).first.dingtalk_account_number.blank?
              #     send_people_dd.concat(User.where(:id => information.id).first.dingtalk_account_number).concat("|")
              #   end
              # end
              
              if !send_people_dd.blank?
                send_by_dingtalk send_people_dd
              end
            end
          end
        end
    end
end
unless Journal.included_modules.include?(RedmineQyWechat::Patches::CorpWechatsJournalsPatch)
  Journal.send(:include, RedmineQyWechat::Patches::CorpWechatsJournalsPatch)
end

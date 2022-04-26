module RedmineQyWechat
  module Patches
    module IssuesControllerPatch
     def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          #alias_method_chain :build_new_issue_from_params, :qy_wechat
          # 兼容4.0
          alias_method :create_without_corp_wechat, :create
          alias_method :create, :create_with_corp_wechat
        end
     end
     
     module InstanceMethods
       
       #def build_new_issue_from_params_with_qy_wechat
       #   build_new_issue_from_params_without_qy_wechat
       #   return if @issue.blank?
       #   @qy_wechat = QyWechat.first
       # end
       
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
            @group_client.message.send_text(send_people_wx, "", "", app_id,"#{l(:msg_focus)} <a href=\'" + Setting.protocol + "://" + Setting.host_name + "/issues/#{@issue.id}\'>#{@issue.tracker} ##{@issue.id}: #{@issue.subject}</a> #{l(:msg_by)} <a href=\'javascript:void(0);\'>#{@issue.author}</a> #{l(:msg_created)}")
          end
        rescue
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
        
          # issue_url = issue_url(@issue)
          issue_url =  Setting.protocol + "://" + Setting.host_name + "/issues/#{@issue.id}"
          issue_title = @issue.project.name
          
          issue_text = "#{@issue.tracker} ##{@issue.id}: #{@issue.subject} #{l(:msg_by)} #{@issue.author} #{l(:msg_created)}"
        
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
       
      def create_with_corp_wechat
          create_without_corp_wechat
          # redmine 5 需要屏蔽调用@issue.save，否则会报错
          # if @issue.save
            # 需要接受微信和钉钉的用户ID集合
            send_people_wx = ""
            send_people_dd = ""
            
            
            to_users = @issue.notified_users
            cc_users = @issue.notified_watchers - to_users
            notify_users = to_users + cc_users

      
            # 用@issue自带的方法获取需要通知的用户列表
            
            notify_users.each do |user|
              unless user.corp_wechat_account_number.blank?
                send_people_wx.concat(user.corp_wechat_account_number).concat("|")
              end
              unless user.dingtalk_account_number.blank?
                send_people_dd.concat(user.dingtalk_account_number).concat("|")
              end
            end
            
            # 推微信
            if !send_people_wx.blank?
              send_by_wechat send_people_wx
            end

            # 推钉钉
            if !send_people_dd.blank?
              send_by_dingtalk send_people_dd
            end
          # end
        end
      end
    end
  end
end
unless IssuesController.included_modules.include?(RedmineQyWechat::Patches::IssuesControllerPatch)
  IssuesController.send(:include, RedmineQyWechat::Patches::IssuesControllerPatch)
end
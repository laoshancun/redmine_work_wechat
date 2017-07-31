module RedmineQyWechat
  module Patches
    module IssuesControllerPatch
     def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          #alias_method_chain :build_new_issue_from_params, :qy_wechat
          alias_method_chain :create, :corp_wechat
        end
     end
     
     module InstanceMethods
       
       #def build_new_issue_from_params_with_qy_wechat
       #   build_new_issue_from_params_without_qy_wechat
       #   return if @issue.blank?
       #   @qy_wechat = QyWechat.first
       # end
       
       def create_with_corp_wechat
          create_without_corp_wechat
          if @issue.save
            
            # 需要接受微信信息的用户微信ID集合
            send_people = ""
            
            # 作者
            unless @issue.author_id.nil?
              unless User.where(:id => @issue.author_id).first.corp_wechat_account_number.blank?
                send_people.concat(User.where(:id => @issue.author_id).first.corp_wechat_account_number).concat("|")
              end
            end
            
            # 指派者
            unless @issue.assigned_to_id.nil?
              unless User.where(:id => @issue.assigned_to_id).first.corp_wechat_account_number.blank?
                send_people.concat(User.where(:id => @issue.assigned_to_id).first.corp_wechat_account_number).concat("|")
              end
            end

            # 关注者
            @issue.watcher_users.each do |information|
              unless User.where(:id => information.id).first.corp_wechat_account_number.blank?
                send_people.concat(User.where(:id => information.id).first.corp_wechat_account_number).concat("|")
              end
            end

            @corp_wechat = CorpWechat.first
            
            if @corp_wechat.blank?
              return
            end
            
            #填写确认并应用的企业ID
            corpid = @corp_wechat.corp_id
            #填写确认并应用的应用Secret
            corpsecret = @corp_wechat.corp_secret
            @group_client = QyWechatApi::Client.new(corpid, corpsecret)
            # 为了确保用户输入的corpid, corpsecret是准确的，请务必执行：
            
            if corpid.blank? || corpsecret.blank? || @group_client.blank?
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
  
                @group_client.message.send_text(send_people, "", "", @corp_wechat.app_id,"#{l(:msg_focus)} <a href=\'" + Setting.host_name + "/issues/#{@issue.id}\'>#{@issue.tracker} ##{@issue.id}: #{@issue.subject}</a> #{l(:msg_by)} <a href=\'javascript:void(0);\'>#{@issue.author}</a> #{l(:msg_created)}")              
              end
            rescue
              return
            end
          end
        end
      end
    end
  end
end
unless IssuesController.included_modules.include?(RedmineQyWechat::Patches::IssuesControllerPatch)
  IssuesController.send(:include, RedmineQyWechat::Patches::IssuesControllerPatch)
end
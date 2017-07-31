module CorpWechatsJournalsPatch
  extend ActiveSupport::Concern
  # 当创建journal时发送消息
  included do
    after_create :send_messages_after_create_journal
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
    issue = journalized
    @issue = issue
    
    if notify?
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
      
      #填写确认并应用的企业ID
      corpid = Setting["plugin_redmine_work_wechat"][:wechat_corp_id]
      #填写确认并应用的应用Secret
      corpsecret = Setting["plugin_redmine_work_wechat"][:wechat_app_secret]
      
      app_id = Setting["plugin_redmine_work_wechat"][:wechat_app_id]
            
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
  
        @group_client.message.send_text(send_people, "", "", app_id,
        "#{l(:msg_focus)} <a href=\'" + Setting.host_name + "/issues/#{@issue.id}\'>#{@issue.tracker} ##{@issue.id}: #{@issue.subject}</a> #{l(:msg_by)} <a href=\'javascript:void(0);\'>#{@issue.journals.last.user}</a> #{l(:msg_updated)}")
      end
      rescue
        return
      end
    end
  end
end

Journal.send(:include, CorpWechatsJournalsPatch)

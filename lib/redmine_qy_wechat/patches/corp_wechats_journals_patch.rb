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
    @journal = @issue.journals.last
    if notify? && (Setting.plugin_redmine_app_notifications.include?('issue_updated') ||
        (Setting.plugin_redmine_app_notifications.include?('issue_note_added') && journal.notes.present?) ||
        (Setting.plugin_redmine_app_notifications.include?('issue_status_updated') && journal.new_status.present?) ||
        (Setting.plugin_redmine_app_notifications.include?('issue_assigned_to_updated') && journal.detail_for_attribute('assigned_to_id').present?) ||
        (Setting.plugin_redmine_app_notifications.include?('issue_priority_updated') && journal.new_value_for('priority_id').present?)
      )
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
      #填写确认并应用的企业ID
      corpid = @corp_wechat.corp_id
      #填写确认并应用的应用Secret
      corpsecret = @corp_wechat.corp_secret
      @group_client = QyWechatApi::Client.new(corpid, corpsecret)
      # 为了确保用户输入的corpid, corpsecret是准确的，请务必执行：
      @group_client.is_valid?
      
      #options = {access_token: "access_token"}
      # redis_key 也可定制
      #group_client = QyWechatApi::Client.new(corpid, corpsecret, options)
      #issue
      #填写确认并应用的应用AgentId
      @group_client.message.send_text(send_people, "", "", @corp_wechat.app_id,
      "您关注的任务 <a href=\'http://proj.tecsoon.cn/issues/#{@issue.id}\'>#{@issue.tracker} ##{@issue.id}: #{@issue.subject}</a> 已被 <a href=\'javascript:void(0);\'>#{@issue.journals.last.user}</a> 更新 ")
    end
  end
end

Journal.send(:include, CorpWechatsJournalsPatch)

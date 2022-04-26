# patches
require File.expand_path('../redmine_qy_wechat/patches/issues_controller_patch', __FILE__)
require File.expand_path('../redmine_qy_wechat/patches/corp_wechats_journals_patch', __FILE__)
require File.expand_path('../redmine_qy_wechat/patches/project_patch', __FILE__)
require File.expand_path('../redmine_qy_wechat/patches/user_patch', __FILE__)
require File.expand_path('../redmine_qy_wechat/patches/account_controller_patch', __FILE__)
# hooks
require File.expand_path('../redmine_qy_wechat/hooks/views_users_hook', __FILE__)
require File.expand_path('../redmine_qy_wechat/hooks/work_wechat_hook_listener', __FILE__)

# 以上适配redmine5，以下是原有代码注释掉
## patches
# require_dependency 'redmine_qy_wechat/patches/issues_controller_patch'
# require_dependency 'redmine_qy_wechat/patches/corp_wechats_journals_patch'
# #require_dependency 'redmine_qy_wechat/patches/users_controller_patch'
# require_dependency 'redmine_qy_wechat/patches/project_patch'
# require_dependency 'redmine_qy_wechat/patches/user_patch'
# require_dependency 'redmine_qy_wechat/patches/account_controller_patch'
## hooks
# require_dependency 'redmine_qy_wechat/hooks/views_users_hook'
# require_dependency 'redmine_qy_wechat/hooks/work_wechat_hook_listener'
module QyWechat
  def self.settings() Setting[:plugin_redmine_qy_wechat].blank? ? {} : Setting[:plugin_redmine_qy_wechat]  end
end

Redmine::Plugin.register :redmine_work_wechat do
  name 'Redmine Work Wechat & Dingtalk plugin'
  author 'laoshancun and Tigergm and Tecsoon team'
  description 'This is a plugin of Work Wechat and Dingtalk for Redmine. fork from https://gitee.com/tigergm/redmine_work_wechat'
  version '0.3.1'
  url 'https://github.com/laoshancun/redmine_work_wechat'
  author_url 'https://github.com/laoshancun'
  
  permission :corp_wechats, { :corp_wechats => [:new] }, :public => true
  menu :admin_menu, :corp_wechats, {:controller => 'settings', :action => 'plugin', :id => "redmine_work_wechat"},:caption => :menu_qy_wechats
                      
  settings :default => {
  }, :partial => 'settings/corp_wechat'
                      
  # Redmine::Search.map do |search|
  #   search.register :corp_wechats
  # end
end
# require_dependency 'redmine_qy_wechat'
require File.expand_path('../lib/redmine_qy_wechat', __FILE__)

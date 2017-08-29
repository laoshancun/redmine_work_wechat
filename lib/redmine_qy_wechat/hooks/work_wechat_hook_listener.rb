class WorkWechatHookListener < Redmine::Hook::ViewListener
  render_on :view_account_login_bottom, :partial => "account/login_dingtalk"
end
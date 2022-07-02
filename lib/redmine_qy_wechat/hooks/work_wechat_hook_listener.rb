module RedmineQyWechat
	module Hooks
		class WorkWechatHookListener < Redmine::Hook::ViewListener
			# render_on :view_account_login_bottom, :partial => "account/login_qrcode"
			def view_account_login_bottom(context = {})
				context[:controller].send(:render_to_string, {
				:partial => "account/login_qrcode",
				:locals => context})
			end
			render_on :view_issues_show_details_bottom, :partial => "issues/dingtalk_flow"
		end
	end
end

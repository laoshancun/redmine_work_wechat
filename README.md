# README #
### 简介 ###

This is a plugin for Wechat of work which is the biggest IM in China. Wechat of work is only oriented to medium-sized and small enterprises in China. So we just introduce it in Chinese.

该插件是企业微信的消息推送插件，企业微信的官方地址是work.weixin.qq.com，不是微信或微信企业公众号（目前了解到，微信企业号也能够支持）。
该插件实现企业微信的某个企业群体的remdine消息推送，适用于已经使用企业微信做沟通和管理的企业。

### 企业微信消息插件安装指南 ###

1、下载源码压缩包，展开到redmine的plugins目录下，保证有redmine_work_wechat目录。

2、安装必要的gem类库，如果是生产环境，则建议带--without参数：

bundle install –-without development test

注：如果是大陆内的网络，最好把redmine根目录下的Gemfile第一行的source 'https://rubygems.org'，改为source 'http://gems.china-ruby.org'

3、执行数据迁移：

rake redmine:plugins:migrate NAME=redmine_work_wechat RAILS_ENV=production

4、重启redmine，进入管理菜单的企业微信配置：


1）前提条件是，在企业微信网站以管理员登录：

https://work.weixin.qq.com

在企业应用中添加应用并保存，根据情况设置合适的可见范围和维护其他内容，获得该应用的agentID和Secret序列号

进入我的企业，获得企业名称和CorpID。

2）以上做完之后，回到redmine，点击新建企业微信应用，根据企业微信管理后台的信息，创建一条记录：

注意！！！从0.0.7版本开始，就直接在配置界面维护，不需要新建记录，原来老版本的请注意重新维护一下配置信息，以前的新建记录将不再生效，除非不想升级。

企业名称对应企业微信后台的企业简称

企业ID对应企业微信后台的CorpID

应用名称对应企业微信后台需要关联应用的名称

应用Secret对应企业微信后台需要关联应用的Secret

应用ID对应企业微信后台需要关联应用的AgentId

然后保存，就会形成一条企业微信配置记录，不要再新建额外的记录。

3）进入用户的维护界面，在企业微信属性，输入用户的企业微信账号（需要在企业微信后台进行查看）。管理员可以统一维护，用户也可以维护自己的账户信息进行维护。

4）创建问题时，就会向相关跟踪或指派的用户（已关联上企业微信账号）推送企业微信消息。

5）另外，注意在系统管理员的管理->配置中，注意维护正确的主机地址，这样才能保证推送的信息链接没问题。

### 贡献人员 ###

 主要由深圳德讯开发团队开发并完成，感谢GracieYu，MiseryT，Daxiang等。
 感谢「微笑、晴天，确认了也能够支持微信企业号，并指出文档说明问题。
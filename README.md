# README #
### 简介 ###

This is a plugin for Wechat of work which is the biggest IM in China. Wechat of work is only oriented to medium-sized and small enterprises in China. So we just introduce it in Chinese.
Later I have added the feature of Dingtalk which is the earliest mobile app for work and is a competitor toward Work Wechat.

该插件是企业微信的消息推送插件，企业微信的官方地址是work.weixin.qq.com，不是微信或微信企业公众号（目前了解到，微信企业号也能够支持）。
该插件实现企业微信的某个企业群体的remdine消息推送，适用于已经使用企业微信做沟通和管理的企业。
自0.0.8版本，又增加了钉钉的消息推送，理论上，有两个平台的应用，配置正确后，都会进行消息推送，甚至同时推送，但一般来讲，一个企业会选择其中之一作为移动办公之选，不用的平台，管理配置里置空就好。
该插件继续保留企业微信的名称，以后视情况做调整，如果集成了钉钉更多的功能，比如单点登录等，可能会考虑更改插件名称。
由于钉钉功能只是初步加入，可能会有很多缺陷，另外，其安装细节以后有时间补充，与企业微信类同，一般是在钉钉的管理后台创建微应用，记录企业标识、创建企业secret，记录该应用标识，填入到插件配置的钉钉配置里，然后再在用户账户里，填入所对应的钉钉账户标识，就可以实现钉钉信息推送。

最新插件已经初步集成了钉钉扫码登录的功能，插件名称也适当调整，该功能需要钉钉后台以开发者登录，创建自助登录应用，记录相应的应用ID、Secret和回调地址，并照着写入到企业微信和钉钉插件的配置界面的钉钉扫码登录的栏目里，回调地址一定要在钉钉里设定为redmine的登录地址，比如http://www.redmineurl.com/login。
当前的机制比较简单，登录时首先看是否在插件配置里配置了钉钉扫码登录信息，如果都配置了，则会在登录界面下方显示钉钉的二维码；
用手机上的钉钉app扫描二维码，并授权登录，此时登录界面会判断是否有用户绑定了该钉钉的ID，如果存在，则自动登录，无需输入用户名和密码，如没有绑定，此时可以输入用户名和密码登录，成功登陆后自动绑定。
如果想取消或者更改当前redmine用户的钉钉绑定，可以在我的账户里，把钉钉唯一标识字段置空，即可。

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

另外，务必保证配置信息的准确无误，错一个符号都可能导致不能正常推送企业微信消息。

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
 感谢Isaac Liu在技术上的大力支持，也感谢中国最大的Redmine qq讨论群（138524445）。
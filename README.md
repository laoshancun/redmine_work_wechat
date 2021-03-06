# README #
### 简介 ###

based on https://gitee.com/tigergm/redmine_work_wechat

This is a plugin for Wechat of work and Dingtalk which both are the biggest IM of work in China. Wechat of work is only oriented to medium-sized and small enterprises in China. Dingtalk only belongs to the cool Chinese companies. So we just introduce them in Chinese.

Both are competing against each other in China but they all benefit the Chinese mobile work field. I combined their APIs into one plugin for redmine.

该插件是企业微信的消息推送插件，企业微信的官方地址是work.weixin.qq.com，不是微信或微信企业公众号（目前了解到，微信企业号也能够支持）。
该插件实现企业微信的某个企业群体的remdine消息推送，适用于已经使用企业微信做沟通和管理的企业。
自0.0.8版本，又增加了钉钉的消息推送，理论上，有两个平台的应用，配置正确后，都会进行消息推送，甚至同时推送，但一般来讲，一个企业会选择其中之一作为移动办公之选，不用的平台，管理配置里置空就好。
该插件继续保留企业微信的名称，以后视情况做调整，如果集成了钉钉更多的功能，比如单点登录等，可能会考虑更改插件名称。
由于钉钉功能只是初步加入，可能会有很多缺陷，另外，其安装细节以后有时间补充，与企业微信类同，一般是在钉钉的管理后台创建微应用，记录企业标识、创建企业secret，记录该应用标识，填入到插件配置的钉钉配置里，然后再在用户账户里，填入所对应的钉钉账户标识（一定是员工UserID，而不是工号），就可以实现钉钉信息推送。

最新插件已经初步集成了钉钉扫码登录的功能，插件名称也适当调整，该功能需要钉钉后台以开发者登录，创建自助登录应用，记录相应的应用ID、Secret和回调地址，并照着写入到企业微信和钉钉插件的配置界面的钉钉扫码登录的栏目里，回调地址一定要在钉钉里设定为redmine的登录地址，比如http://www.redmineurl.com/login。
当前的机制比较简单，登录时首先看是否在插件配置里设定了钉钉扫码登录信息，如果都配置了，则会在登录界面下方显示钉钉的二维码；
用手机上的钉钉app扫描二维码，并授权登录，此时登录界面会判断是否有用户绑定了该钉钉的ID，如果存在，则自动登录，无需输入用户名和密码，如没有绑定，此时可以输入用户名和密码登录，成功登陆后自动绑定。
如果想取消或者更改当前redmine用户的钉钉绑定，可以在我的账户里，把钉钉唯一标识字段置空，即可。
以上的设定细节比较多，需要具备一定的开发基础和钉钉后台的设置经验。另外，初步实现会有很多缺陷和使用上的不完善，以后慢慢优化。

自0.1.6版，加入issue中可以启用钉钉审批，配置过程比较复杂，大概流程先描述一下：首先，管理员在配置工作台中，新增一个审批，增加审批表单的属性是4个单行编辑器（一定是单行编辑器，dingtalk只支持有限的三种界面类型，不支持日期、数字、多行和文本等），依次命名为“项目”、“Issue号”、“标题”、“内容”。
然后，记录此流程的编号，在插件配置里写入，配置一个部门，记录下部门id，尽量包含redmine中需要参与审批的用户，也在插件配置中写入此部门id。
注意同时利用消息推送的appid等信息即可。每个issue会有启动钉钉审批流程的连接，如果配置信息都正确，会在钉钉中发起审批，作者就是发起人，指派人未审批者，跟踪者为抄送者。
以上功能暂时先简单实现，后期看情况优化，比如增加查看dingtalk的审批状态，按照项目配置不同的审批部门或是否启用审批流程等。功能很不完善，请有一定开发基础的试用，其他人慎用。也不要想能够发起请假等标准流程（因为dingtalk的api受限）。

自0.2.0版，加入钉钉APP内的免登功能，如果从钉钉APP内的消息或者工作台中进入redmine，可以无需输入用户名和密码，凭借钉钉用户授权就可以直接登录。前提是启用扫码登录功能，这个便捷功能才能生效。

自0.2.5版，屏蔽有关钉钉审批的实验性代码，关闭相关的配置选项，以减少该插件的复杂度，避免造成误解。

自0.3.1版，新增企业微信扫码登录。

=======
注意：当前插件不支持Windows系统下的服务，比如BitName一键安装或者自行在Windows下配置的Rails环境等。该问题应该在0.2.2版本后修复。

另外钉钉方面有些注意事项，配置时要注意：
1、信息推送只在插件配置里设定前三个字段就好了，一定确保CorpId，Secret和AgentId的完全正确；

2、在钉钉管理后台创建自建应用即可，不是其他类型的应用（比如E应用）；

3、信息推送复用了redmine的邮件通知选项和用户的通知设置（无论是否配置了邮件服务，都没有关系），所以注意不要禁用发送邮件通知活动的选项和用户中的邮件通知设置，比如取消勾选不要发送对我自己提交...；

4、目前钉钉是通过UserID来做信息推送和免登的，注意统一维护到redmine里的用户相关字段，由于安全原因，禁止普通用户维护自己的UserID；

5、钉钉信息推送也要注意在https://open-dev.dingtalk.com里，维护好redmine服务器的IP白名单，否则收不到钉钉的信息推送；

6、通过钉钉唯一id做扫描登录，扫码需要到https://open-dev.dingtalk.com的自助工具里，创建扫码登录应用授权，并注意填写回调地址为redmine的login地址。


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

在企业应用中添加应用并保存，根据情况设置合适的可见范围和维护其他内容，获得该应用的agentID和Secret序列号。

以上，最新版本的企业微信管理后台的菜单名称改为应用管理，需要在自建类里点击创建应用按钮。

进入我的企业，获得企业名称和CorpID。

2）以上做完之后，回到redmine，点击新建企业微信应用，根据企业微信管理后台的信息，创建一条记录：

注意！！！从0.0.7版本开始，就直接在配置界面维护，不需要新建记录，原来老版本的请注意重新维护一下配置信息，以前的新建记录将不再生效，除非不想升级。

另外，务必保证配置信息的准确无误，错一个符号都可能导致不能正常推送企业微信消息。

企业名称对应企业微信后台的企业简称；

企业ID对应企业微信后台的CorpID；

应用名称对应企业微信后台需要关联应用的名称；

应用Secret对应企业微信后台需要关联应用的Secret，最新版本的后台管理需要发送Secret密文；

应用ID对应企业微信后台需要关联应用的AgentId；

然后保存，就会形成一条企业微信配置记录，不要再新建额外的记录。

3）进入用户的维护界面，在企业微信属性，输入用户的企业微信账号（需要在企业微信后台进行查看）。管理员可以统一维护，用户也可以维护自己的账户信息进行维护。

4）创建问题时，就会向相关跟踪或指派的用户（已关联上企业微信账号）推送企业微信消息。

5）另外，注意在系统管理员的管理->配置中，注意维护正确的主机地址，这样才能保证推送的信息链接没问题。


### bitnami windows版安装指南 ###
如果环境是bitnami一键式安装并且是windows环境，经过验证需要这样处理：

1）源码的windows目录下，有支持libcurl的动态库，这个是推送消息的底层支持组件，是必须具备的，把此文件放到bitnami的ruby/bin目录下，从而能够在执行插件数据迁移时通过。

2）执行命令bundle install和rake redmine:plugins:migrate NAME=redmine_work_wechat RAILS_ENV=production时，需要提前把bitnami下的ruby/bin目录加入到windows的Path系统路径中，这样才能保证这些命令正常执行。

3）在执行rake redmine:plugins:migrate NAME=redmine_work_wechat RAILS_ENV=production时，会提示rake版本问题，此时，只要加入bundle exec即可，完整命令如下：

bundle exec rake redmine:plugins:migrate NAME=redmine_work_wechat RAILS_ENV=production

4）如果没有在ruby/bin里放置libcurl.dll动态链文件，执行3）步骤会提示缺少此类类库的问题，如果已放置了，则能正常执行。

5）执行完成之后，需要重启bitnami的全部服务，等待一会儿，进入redmine才能看到插件功能生效，配置方法不变。

以上经过4.2.4版本的bitnami-redmine-4.2.4-0-windows-x64-installer.exe在win10下验证过。

其他版本的windows下安装，解决思路和方法应该一致。

### 重要事项 ###
20220426，0.3.0是初步适配redmine 5的版本，不一定适用于redmine 4和redmine 3，还未做充分验证；另外，适配redmine 5的插件版本可能有一些未知的缺陷，后续逐渐发现和修复，慢慢升级优化。

### 贡献人员 ###

 主要由深圳德讯开发团队开发并完成，感谢GracieYu，MiseryT，Daxiang等。
 感谢「微笑、晴天，确认了也能够支持微信企业号，并指出文档说明问题。
 感谢沧海云帆，推进免登功能的开发和测试。
 感谢Isaac Liu在技术上的大力支持，也感谢中国最大的Redmine qq讨论群（138524445）。

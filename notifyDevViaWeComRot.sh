#!/bin/bash
# 通过匹配传入的姓名变量，通过企业微信机器人发送通知
if [ $# -lt 4 ];
then
    echo "传递参数错误,小于4个参数!";
    exit 1;
else
    appName=$1;
    weixinWebhook=$2;
    reportType=$3;
    commitUserName=$4;
    reportUrl=$5;
    devPhone='all';
    echo "传入参数--应用名：${appName} 机器人hook：${weixinWebhook} 类型：${reportType} 姓名：${commitUserName} 报告链接：${reportUrl}";
    if [[ "$commitUserName" =~ .*伟 ]];
    then
        # 张 伟
        devPhone='110';
    elif [[ "$commitUserName" =~ .*梅梅 ]];
    then
        # 韩梅梅
        devPhone='120';
    elif [[ "$commitUserName" =~ .*华强 ]];
    then
        # 华强 李
        devPhone='130';
    else
        echo "名字不匹配!";
    fi
    # 执行 python 命令，把传入的提交者名字中的空格去掉
    commitUserName=$(python -c "import sys; print sys.argv[1].replace(' ', '')"  "$commitUserName");
    echo "去除空格后姓名：${commitUserName}";
    # 根据传入类型选择发送文本
    if (( ${reportType}==0 ));
    then
        #报告不符合代码规范
        curl ${weixinWebhook}  -H 'Content-Type:application/json;' -g -d '{"msgtype": "text","text": {"content": "**'$appName'合并代码失败:**\n提交人:'$commitUserName'\n请注意代码规范,具体信息请访问 '$reportUrl' 查看","mentioned_mobile_list":["'$devPhone'"]}}';
    elif (( ${reportType}==1 ));
    then
        #报告合并请求冲突
        curl ${weixinWebhook}  -H 'Content-Type:application/json;' -g -d '{"msgtype": "text","text": {"content": "**'$appName'合并代码失败:**\n提交人:'$commitUserName'\n与目标分支存在冲突，可能是落后提交，请先合并目标分支代码到源分支","mentioned_mobile_list":["'$devPhone'"]}}';
    else
        echo "类型不匹配!";
    fi
fi
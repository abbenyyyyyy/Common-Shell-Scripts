#!/bin/bash
# 使用360加固apk，然后将加固后的apk上传到蒲公英
if [ $# -lt 10 ];
then
    echo "传递参数错误,小于10个参数!";
    exit 1;
else
    # 打包出来的APK根目录，例如 /usr/local/wordcode/demo/app/build/outputs/apk/release
    appProjectDir=$1;
    # 360加固的目录，例如 /usr/local/share/jiagu/jiagu.jar
    JiaguJarDir=$2;
    user360=$3;
    password360=$4;
    # 签名文件目录 如./app/dsl_shopassistant.jks
    signDir=$5;
    signPassword=$6;
    signAlias=$7;
    signAliasPassword=$8;
    userKey=$9;
    apikey=$10;
    echo "传入参数--apk所在的文件夹目录：${appProjectDir} 360jar目录：${JiaguJarDir} 账号：${user360} 密码：${password360} 签名路径：${signDir} 签名密码：${signPassword} 签名Alias：${signAlias} 签名Alias密码：${signAliasPassword} 蒲公英密钥：${userKey} 蒲公英密钥：${apikey} ";
    #在apk所在的文件夹目录新建一个timestampFile文件
    timestampFileDir="${appProjectDir}/timestampFile"
    touch ${timestampFileDir}
	  # 登录360加固
	  java -jar ${JiaguJarDir} -login ${user360} ${password360}
	  # 配置360加固签名
	  java -jar ${JiaguJarDir} -importsign ${signDir} ${signPassword} ${signAlias} ${signAliasPassword}
	  java -jar ${JiaguJarDir} -showsign
	  # 不要增强服务：崩溃日志、x86架构、加固数据分析、盗版监测
	  java -jar ${JiaguJarDir} -config
	  # 显示360加固已选择加固配置
	  java -jar ${JiaguJarDir} -showconfig
	  # 开启360加固并对加固包重签名
	  java -jar ${JiaguJarDir} -jiagu "${appProjectDir}/app-release.apk" "${appProjectDir}/" -autosign
	  targetApk=`find ${appProjectDir} -name "*.apk" -newer ${timestampFileDir}`
    echo '结果：'+$targetApk
    # 上传到蒲公英
    curl -F "file=@${targetApk}" -F "uKey=${userKey}" -F "_api_key=${apikey}" -F "updateDescription=上传备注" https://qiniu-storage.pgyer.com/apiv1/app/upload
fi
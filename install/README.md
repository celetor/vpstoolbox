# 项目组件安装脚本文件夹

## 此文件夹为项目模块化的结果

## PR规则

1. 仅支援.sh文件

sh内容样本,**pr请严格按照此样本,否则拒接**,谢谢 !

> xxx为软件名称

```shell
#!/usr/bin/env bash

## xxx模组 xxx moudle

## Official Docs/Github url : https://github.com/xxx/xxx/master/

install_xxx(){
    ## 安装命令
    ...
    ## 若有Nginx相关config,请严格按照以下样板
    # cat > '/etc/nginx/conf.d/xxx.conf' << EOF
    # location ${filepath} {
    # other nginx config;
	# access_log off;
	# proxy_pass http://127.0.0.1:8081/;
	# client_max_body_size 0;
    # }
    # EOF
}
```

2. 请说明软件的用处等。

3. 任何人都可以pr,只要遵守样本即可。
server{
    listen 80;
    server_name rest.yaf.com;
    root /Users/qiang/code/jhq0113/elephant/rest/public;
    index index.php;

    try_files $uri $uri/ @rewrite;

    location @rewrite {
        rewrite ^/(.*)  /index.php/$1 last;
    }

    location ~ \.php {
        #设置dns
        resolver 8.8.8.8;
        default_type 'text/plain';
        #rewrite增加header头
        rewrite_by_lua_block {
            require("lion.application").rewrite()
        }

        fastcgi_index  /index.php;
        fastcgi_pass   127.0.0.1:9000;
        include fastcgi_params;
        fastcgi_split_path_info       ^(.+\.php)(/.+)$;
        fastcgi_param PATH_INFO       $fastcgi_path_info;
        fastcgi_param PATH_TRANSLATED $document_root$fastcgi_path_info;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }

   access_log logs/rest.yaf.com.log main;

   #定义错误日志及级别
   error_log  logs/rest.yaf.com.error.log info;
}

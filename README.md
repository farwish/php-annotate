# php-annotate

> 当前版本php5.6.*，和php-src目录结构对应.

## 从何处开始读 

./buildconf # 最终有用的是最后一行 make -s -f build/build.mk  

./build/build.mk  # 注意里面的三个目标 all, generated_lists, buildmk.stamp 执行的命令.  

./build/build2.mk  # build.mk 中生成 generated_lists 文件，最终由 build2.mk 使用.  

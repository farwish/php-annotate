#  +----------------------------------------------------------------------+
#  | PHP Version 5                                                        |
#  +----------------------------------------------------------------------+
#  | Copyright (c) 1997-2016 The PHP Group                                |
#  +----------------------------------------------------------------------+
#  | This source file is subject to version 3.01 of the PHP license,      |
#  | that is bundled with this package in the file LICENSE, and is        |
#  | available through the world-wide-web at the following url:           |
#  | http://www.php.net/license/3_01.txt                                  |
#  | If you did not receive a copy of the PHP license and are unable to   |
#  | obtain it through the world-wide-web, please send a note to          |
#  | license@php.net so we can mail you a copy immediately.               |
#  +----------------------------------------------------------------------+
#  | Author: Sascha Schumann <sascha@schumann.cx>                         |
#  +----------------------------------------------------------------------+
#
#
# Makefile to generate build tools
#

# 变量赋值.
SUBDIRS = Zend TSRM

STAMP = buildmk.stamp

ALWAYS = generated_lists

# 没有 make -f 指定 target，第一个总是默认目标，后面是依赖文件。
# （ 命令编译 build/build2.mk，@ 不显示执行过程. ）
# 没有找到依赖的情况下，会先执行下面的.
all: $(STAMP) $(ALWAYS)
	@$(MAKE) -s -f build/build2.mk

# make -f build/build.mk generated_lists 查看效果。
# generated_lists 文件包含两个变量 makefile_am_files config_m4_files.
generated_lists:
	@echo makefile_am_files = Zend/Makefile.am TSRM/Makefile.am > $@
	@echo config_m4_files = Zend/Zend.m4 TSRM/tsrm.m4 TSRM/threads.m4 \
		Zend/acinclude.m4 ext/*/config*.m4 sapi/*/config.m4 >> $@

# make -f build/build.mk buildmk.stamp 查看效果。
# 检测 buildconf 并生成 buildmk.stamp.
$(STAMP): build/buildcheck.sh
	@build/buildcheck.sh $(STAMP)

snapshot:
	distname='$(DISTNAME)'; \
	if test -z "$$distname"; then \
		distname='php5-snapshot'; \
	fi; \
	myname=`basename \`pwd\`` ; \
	cd .. && cp -rp $$myname $$distname; \
	cd $$distname; \
	rm -f $(SUBDIRS) 2>/dev/null || true; \
	for i in $(SUBDIRS); do \
		test -d $$i || (test -d ../$$i && cp -rp ../$$i $$i); \
	done; \
	find . -type l -exec rm {} \; ; \
	$(MAKE) -f build/build.mk; \
	cd ..; \
	tar cf $$distname.tar $$distname; \
	rm -rf $$distname $$distname.tar.*; \
	bzip2 -9 $$distname.tar; \
	md5sum $$distname.tar.bz2; \
	sync; sleep 2; \
	md5sum $$distname.tar.bz2; \
	bzip2 -t $$distname.tar.bz2

gitclean-work:
	@if (test ! -f '.git/info/exclude' || grep -s "git-ls-files" .git/info/exclude); then \
		(echo "Rebuild .git/info/exclude" && echo '*.o' > .git/info/exclude && git svn propget svn:ignore | grep -v config.nice >> .git/info/exclude); \
	fi; \
	git clean -X -f -d;

# buildmk.stamp snapshot 都是伪目标。
# make -f build/build.mk buildmk.stamp / make -f build/build.mk snapshot
.PHONY: $(ALWAYS) snapshot

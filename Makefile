PKG_SRC_NAME = freeradius-server-2.1.9.tar.gz
PKG_SRC_DIR = freeradius-server-2.1.9
PREFIX_BUILD_DIR = /usr/joe/freeradius-server
SIM_FILES_DIR = $(CURDIR)/$(PKG_SRC_DIR)/src/modules/rlm_sim_files


ifeq ("$(PREFIX_BUILD_DIR)","")
#default prefix
PREFIX_BUILD_DIR = /usr/local
endif


define Host/Prepare
	apt-get install openssl
	apt-get install libssl-dev
	mkdir -p $(PKG_SRC_DIR)
	tar zxvf $(CURDIR)/source/$(PKG_SRC_NAME) --strip 0
	for patch in $(shell ls patches/*.patch 2>/dev/null); do \
		patch -d $(PKG_SRC_DIR) -p1 < $$patch; \
	done
endef

define Host/Configure
	cd $(CURDIR)/$(PKG_SRC_DIR) && ./configure --prefix=$(PREFIX_BUILD_DIR)
endef

define Host/Compile
	$(MAKE) -C $(PKG_SRC_DIR)
endef

define Host/Install
	$(MAKE) -C $(PKG_SRC_DIR) install	;\
	$(MAKE) -C $(SIM_FILES_DIR)	;\
	cp $(SIM_FILES_DIR)/.libs/rlm_sim_files-2.1.9.so $(PREFIX_BUILD_DIR)/lib	;\
	rm -f $(PREFIX_BUILD_DIR)/lib/rlm_sim_files.so	;\
	ln -s $(PREFIX_BUILD_DIR)/lib/rlm_sim_files-2.1.9.so $(PREFIX_BUILD_DIR)/lib/rlm_sim_files.so	;
endef



.PHONY:
all: prepare configure compile install


$(PKG_SRC_DIR)/.prepare_timestamp:
	$(call Host/Prepare)
	touch $@

prepare: $(PKG_SRC_DIR)/.prepare_timestamp
	@echo $@ done

configure:
	$(call Host/Configure)

compile:
	$(call Host/Compile)

install:
	$(call Host/Install)

clean:


########
$(PKG_SRC_DIR)/.git/.git_start_timestamp:
	mkdir -p $(PKG_SRC_DIR)
	tar zxvf $(CURDIR)/source/$(PKG_SRC_NAME) --strip 0
	cd $(PKG_SRC_DIR) && rm -rf .git && git init . && git add -f . && git commit -m init
	for patch in $(shell ls patches/*.patch 2>/dev/null); do \
		(cd $(PKG_SRC_DIR) && git am -k --keep-cr --committer-date-is-author-date) < $$patch; \
	done
	touch $(PKG_SRC_DIR)/.prepare_timestamp
	touch $(PKG_SRC_DIR)/.git/.git_start_timestamp

git_start: $(PKG_SRC_DIR)/.git/.git_start_timestamp
	@echo $@ done

git_export:
	cd $(PKG_SRC_DIR) && \
		git format-patch --binary --no-signature -k $$(git rev-list --max-parents=0 HEAD) -o $(PWD)/patches/ -p
	for patch in $$(ls patches/*.patch 2>/dev/null); do \
		sed -i -e '1d' -e '1,1 s/From.*/From: patch <patch@patch>/' $${patch} #fix git patch header; \
	done
########

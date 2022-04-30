# BASE_DIRECTORY set from cli
GIT_TAG:=fake-tag
GOLANG_VERSION:=1.17

REPO_OWNER:=aws
REPO:=make-test

REPO_NO_CLONE:=true

BASE_IMAGE_NAME=eks-distro-minimal-base

include $(BASE_DIRECTORY)/Override.mk
include $(BASE_DIRECTORY)/Common.mk


$(REPO):
	@mkdir $@
	@git -C $@ init
	@touch $@/Readme
	@git -C $@ add .
	@git -C $@ commit -am "first"
	@git -C $@ tag $(GIT_TAG)

.PHONY: clean-extra
clean-extra:
	@rm -rf $(REPO)

clean: clean-extra

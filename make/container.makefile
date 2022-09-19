#
# Container Image Distribution
#

.PHONY: container-run-linux
container-run-linux:
	$(BIN_DOCKER) container create \
		--platform "$(PROJ_PLATFORM_OS)/$(PROJ_PLATFORM_ARCH)" \
		--name "registry" \
		-h "registry" \
		-u "480" \
		--entrypoint "registry" \
		--net "$(NET_NAME)" \
		-p "443":"443" \
		--health-interval "10s" \
		--health-timeout "8s" \
		--health-retries "3" \
		--health-cmd "registry-healthcheck \"443\" \"8\"" \
		-v "registry":"/usr/local/var/lib/distribution" \
		"$(IMG_REG_URL)/$(IMG_REPO):$(IMG_TAG_PFX)-$(PROJ_PLATFORM_OS)-$(PROJ_PLATFORM_ARCH)" \
		serve "/usr/local/etc/distribution/config.yml"
	$(BIN_FIND) "bin" -mindepth "1" -type "f" -iname "*" -print0 \
	| $(BIN_TAR) -c --numeric-owner --owner "0" --group "0" -f "-" --null -T "-" \
	| $(BIN_DOCKER) container cp "-" "registry":"/usr/local"
	$(BIN_FIND) "etc/distribution" -mindepth "1" -type "f" -iname "*" ! -iname "tls-key.pem" -print0 \
	| $(BIN_TAR) -c --numeric-owner --owner "0" --group "0" -f "-" --null -T "-" \
	| $(BIN_DOCKER) container cp "-" "registry":"/usr/local"
	$(BIN_FIND) "etc/distribution" -mindepth "1" -type "f" -iname "tls-key.pem" -print0 \
	| $(BIN_TAR) -c --numeric-owner --owner "480" --group "480" --mode "600" -f "-" --null -T "-" \
	| $(BIN_DOCKER) container cp "-" "registry":"/usr/local"
	$(BIN_DOCKER) container start -a "registry" 2>&1 \
	| $(BIN_JQ) -R -r -C --unbuffered ". as \$$line | try fromjson catch \$$line"

.PHONY: container-run
container-run:
	$(MAKE) "container-run-$(PROJ_PLATFORM_OS)"

.PHONY: container-rm
container-rm:
	$(BIN_DOCKER) container rm -f "registry"

#
# Container Image Distribution
#

.PHONY: vol-create
vol-create:
	$(BIN_DOCKER) volume create "registry"

.PHONY: vol-rm
vol-rm:
	$(BIN_DOCKER) volume rm "registry"

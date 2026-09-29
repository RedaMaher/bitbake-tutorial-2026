include config.mk

.PHONY: all
all: hello-host

hello-host: $(SRC_DIR)/hello.c config.mk
	$(CC) $(CFLAGS) "$(SRC_DIR)/hello.c" -o "$@"

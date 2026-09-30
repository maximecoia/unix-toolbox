NAME := unix-toolbox
CC ?= cc
CFLAGS := -Wall -Wextra -Werror -std=c99

PROGRAMS := mini_echo mini_cat mini_cp mini_wc
BIN_DIR := bin
TARGETS := $(addprefix $(BIN_DIR)/,$(PROGRAMS))

# The same utilities, rebuilt with every write() sent to tests/short_write.c,
# which writes one byte per call. mini_echo already does, so it is not rebuilt.
SHORT_DIR := $(BIN_DIR)/short
SHORT_PROGRAMS := mini_cat mini_cp mini_wc
SHORT_TARGETS := $(addprefix $(SHORT_DIR)/,$(SHORT_PROGRAMS))
SHORT_OBJECT := $(SHORT_DIR)/short_write.o

.PHONY: all $(PROGRAMS) short status test check clean fclean re help

all: $(TARGETS)

$(PROGRAMS): %: $(BIN_DIR)/%

$(BIN_DIR)/mini_echo: mini_echo/mini_echo.c
$(BIN_DIR)/mini_cat: mini_cat/mini_cat.c
$(BIN_DIR)/mini_cp: mini_cp/mini_cp.c
$(BIN_DIR)/mini_wc: mini_wc/mini_wc.c

$(TARGETS):
	@mkdir -p $(BIN_DIR)
	$(CC) $(CFLAGS) $< -o $@

short: $(SHORT_TARGETS)

# The object is compiled WITHOUT the redirection: inside it, write() has to
# stay the real system call.
$(SHORT_OBJECT): tests/short_write.c
	@mkdir -p $(SHORT_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(SHORT_DIR)/mini_cat: mini_cat/mini_cat.c $(SHORT_OBJECT)
$(SHORT_DIR)/mini_cp: mini_cp/mini_cp.c $(SHORT_OBJECT)
$(SHORT_DIR)/mini_wc: mini_wc/mini_wc.c $(SHORT_OBJECT)

$(SHORT_TARGETS):
	$(CC) $(CFLAGS) -Dwrite=short_write $< $(SHORT_OBJECT) -o $@

status:
	@for program in $(PROGRAMS); do \
		if grep -q 'PROJECT_STATUS: TODO' "$$program/$$program.c"; then \
			printf '%-12s %s\n' "$$program" 'TODO'; \
		else \
			printf '%-12s %s\n' "$$program" 'ACTIVE'; \
		fi; \
	done

test: all short
	@sh tests/run.sh

check:
	@for script in tests/*.sh; do sh -n "$$script"; done
	@$(MAKE) --no-print-directory test

clean:
	@rm -rf $(BIN_DIR)

fclean: clean

re: fclean all

help:
	@printf '%s\n' \
		'Available targets:' \
		'  all          Build every command' \
		'  mini_echo    Build bin/mini_echo' \
		'  mini_cat     Build bin/mini_cat' \
		'  mini_cp      Build bin/mini_cp' \
		'  mini_wc      Build bin/mini_wc' \
		'  short        Build bin/short/, the utilities under one-byte writes' \
		'  status       Show TODO or ACTIVE for each command' \
		'  test         Build and run active behavioral tests' \
		'  check        Validate shell syntax, build, and test' \
		'  clean        Remove compiled binaries' \
		'  fclean       Alias of clean' \
		'  re           Rebuild everything'

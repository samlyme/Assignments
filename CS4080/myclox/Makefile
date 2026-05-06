# Define the compiler
CC = gcc

# Define compiler flags
GPERFTOOLS_PREFIX ?= $(shell brew --prefix gperftools 2>/dev/null)
CPPFLAGS += $(if $(GPERFTOOLS_PREFIX),-I$(GPERFTOOLS_PREFIX)/include)
CFLAGS = -Wall -Wextra -Werror=implicit-function-declaration
LDFLAGS += $(if $(GPERFTOOLS_PREFIX),-L$(GPERFTOOLS_PREFIX)/lib)
LDLIBS += -lprofiler
DEPFLAGS = -MMD -MP

# Define directories
SRC_DIR = src
BUILD_DIR = target
BENCH_DIR = bench
PROF_DIR = prof

# Define the output executable name
TARGET = $(BUILD_DIR)/clox

# Find all .c files in the source directory
SRCS = $(wildcard $(SRC_DIR)/*.c)
BENCHMARKS = $(wildcard $(BENCH_DIR)/*.lox)

# Generate object file paths inside the build directory using patsubst
OBJS = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SRCS))
DEPS = $(OBJS:.o=.d)
PROFILES = $(patsubst $(BENCH_DIR)/%.lox,$(PROF_DIR)/%.out,$(BENCHMARKS))

# Default rule
all: $(TARGET)

# Rule to link the final executable
$(TARGET): $(OBJS) Makefile
	$(CC) $(LDFLAGS) -o $@ $(OBJS) $(LDLIBS)

# Pattern rule to compile .c files into .o files
# Looks for .c files in SRC_DIR and outputs .o files to BUILD_DIR
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c Makefile | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(DEPFLAGS) -c $< -o $@

# Rule to create the build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

repl: $(TARGET)
	./$(TARGET)

run: $(TARGET)
	./$(TARGET) test.lox

perf: $(PROFILES)

$(PROF_DIR)/%.out: $(BENCH_DIR)/%.lox $(TARGET) FORCE | $(PROF_DIR)
	CPUPROFILE=$@ ./$(TARGET) $<

$(PROF_DIR):
	mkdir -p $(PROF_DIR)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean repl run perf FORCE

-include $(DEPS)

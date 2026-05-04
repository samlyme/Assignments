# Define the compiler
CC = gcc

# Define compiler flags
CFLAGS = -Wall -Wextra -Werror=implicit-function-declaration

# Define directories
SRC_DIR = src
BUILD_DIR = target

# Define the output executable name
TARGET = $(BUILD_DIR)/clox

# Find all .c files in the source directory
SRCS = $(wildcard $(SRC_DIR)/*.c)

# Generate object file paths inside the build directory using patsubst
OBJS = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SRCS))

# Default rule
all: $(TARGET)

# Rule to link the final executable
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^

# Pattern rule to compile .c files into .o files
# Looks for .c files in SRC_DIR and outputs .o files to BUILD_DIR
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

# Rule to create the build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

repl: $(TARGET)
	./$(TARGET)

run: $(TARGET)
	./$(TARGET) test.lox

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean repl run

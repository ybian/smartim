CC=/usr/bin/clang
NAME=im-select
OPTS=-framework foundation -framework carbon

all: x86_target arm_target
	lipo -create -output plugin/$(NAME) plugin/$(NAME)_x86 plugin/$(NAME)_arm

x86_target: $(NAME).m
	$(CC) $(OPTS) $(NAME).m -o plugin/$(NAME)_x86 -target x86_64-apple-macos10.12

arm_target: $(NAME).m
	$(CC) $(OPTS) $(NAME).m -o plugin/$(NAME)_arm -target arm64-apple-macos11

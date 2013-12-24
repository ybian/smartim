CC=/usr/bin/clang
NAME=im-select
OPTS=-framework foundation -framework carbon

all:
	$(CC) $(OPTS) -o plugin/$(NAME) $(NAME).m

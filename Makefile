SWIFT=swiftc
NAME=im-select

all:
	$(SWIFT) -o plugin/$(NAME) $(NAME).swift

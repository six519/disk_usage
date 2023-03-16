app_name = usage

.PHONY: clean all

.PRECIOUS: *.o

all: $(app_name)

clean:
	@rm -fv $(app_name).o
	@rm -fv $(app_name)

%.o: %.asm
	nasm -felf64 $<

%: %.o
	gcc $< -o $@

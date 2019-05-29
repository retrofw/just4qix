CHAINPREFIX := /opt/mipsel-linux-uclibc
CROSS_COMPILE := $(CHAINPREFIX)/usr/bin/mipsel-linux-

CC = $(CROSS_COMPILE)gcc
CXX = $(CROSS_COMPILE)g++
STRIP = $(CROSS_COMPILE)strip

SYSROOT     := $(shell $(CXX) --print-sysroot)
SDL_CFLAGS  := $(shell $(SYSROOT)/usr/bin/sdl-config --cflags)
SDL_LIBS    := $(shell $(SYSROOT)/usr/bin/sdl-config --libs)

CFLAGS = $(SDL_CFLAGS) -O2 -ffast-math
LIBS = $(SDL_LIBS) -lSDL -lSDL_mixer

just4qix: src/main.o src/render.o src/update.o src/input.o src/sound.o src/particle.o
	$(CC) src/main.o src/render.o src/update.o src/input.o src/sound.o src/particle.o -o just4qix/just4qix.elf -lSDL -lSDL_mixer

clean:
	rm -rf src/*.o
	rm -rf just4qix/just4qix.elf

ipk: just4qix
	@rm -rf /tmp/.just4qix-ipk/ && mkdir -p /tmp/.just4qix-ipk/root/home/retrofw/games/just4qix /tmp/.just4qix-ipk/root/home/retrofw/apps/gmenu2x/sections/games
	@cp -r just4qix/gfx just4qix/sound just4qix/just4qix.elf just4qix/just4qix.png /tmp/.just4qix-ipk/root/home/retrofw/games/just4qix
	@cp just4qix/just4qix.lnk /tmp/.just4qix-ipk/root/home/retrofw/apps/gmenu2x/sections/games
	@sed "s/^Version:.*/Version: $$(date +%Y%m%d)/" just4qix/control > /tmp/.just4qix-ipk/control
	@cp just4qix/conffiles /tmp/.just4qix-ipk/
	@tar --owner=0 --group=0 -czvf /tmp/.just4qix-ipk/control.tar.gz -C /tmp/.just4qix-ipk/ control conffiles
	@tar --owner=0 --group=0 -czvf /tmp/.just4qix-ipk/data.tar.gz -C /tmp/.just4qix-ipk/root/ .
	@echo 2.0 > /tmp/.just4qix-ipk/debian-binary
	@ar r just4qix/just4qix.ipk /tmp/.just4qix-ipk/control.tar.gz /tmp/.just4qix-ipk/data.tar.gz /tmp/.just4qix-ipk/debian-binary

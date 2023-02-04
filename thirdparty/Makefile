LIB_DIR:=$(shell pwd)/lib
INC_DIR:=$(shell pwd)/include
RAYLIB_DIR:=$(shell pwd)/raylib

default: setup-raylib

.PHONY: \
	default \
	clean \
	setup-raylib

clean:
	rm $(LIB_DIR)/* $(INC_DIR)/*
	$(MAKE) -C $(RAYLIB_DIR)/src clean

setup-raylib: \
	$(INC_DIR)/rlgl.h \
	$(INC_DIR)/raymath.h \
	$(INC_DIR)/raylib.h \
	$(LIB_DIR)/libraylib.a

$(INC_DIR)/rlgl.h:
	cp --update $(RAYLIB_DIR)/src/rlgl.h $@

$(INC_DIR)/raymath.h:
	cp --update $(RAYLIB_DIR)/src/raymath.h $@

$(INC_DIR)/raylib.h: 
	cp --update $(RAYLIB_DIR)/src/raylib.h $@

$(LIB_DIR)/libraylib.a:
	$(MAKE) -C $(RAYLIB_DIR)/src RAYLIB_RELEASE_PATH=$(LIB_DIR)

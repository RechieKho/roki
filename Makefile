PLATFORM?=PLATFORM_DESKTOP
HOST_PLATFORM_OS?=WINDOWS
PLATFORM_OS?=WINDOWS
RAYLIB_BUILD_MODE?=DEBUG

# Use cross-compiler for PLATFORM_RPI.
ifeq ($(PLATFORM),PLATFORM_RPI)
    USE_RPI_CROSS_COMPILER ?= FALSE
    ifeq ($(USE_RPI_CROSS_COMPILER),TRUE)
        RPI_TOOLCHAIN ?= C:/SysGCC/Raspberry
        RPI_TOOLCHAIN_SYSROOT ?= $(RPI_TOOLCHAIN)/arminux-gnueabihf/sysroot
    endif
endif

# Determine PLATFORM_OS in case PLATFORM_DESKTOP selected.
ifeq ($(PLATFORM),PLATFORM_DESKTOP)
    # No uname.exe on MinGW!, but OS=Windows_NT on Windows!
    # ifeq ($(UNAME),Msys) -> Windows
    ifeq ($(OS),Windows_NT)
        PLATFORM_OS = WINDOWS
        ifndef PLATFORM_SHELL
            PLATFORM_SHELL = cmd
        endif
    else
        UNAMEOS = $(shell uname)
        ifeq ($(UNAMEOS),Linux)
            PLATFORM_OS = LINUX
        endif
        ifeq ($(UNAMEOS),FreeBSD)
            PLATFORM_OS = BSD
        endif
        ifeq ($(UNAMEOS),OpenBSD)
            PLATFORM_OS = BSD
        endif
        ifeq ($(UNAMEOS),NetBSD)
            PLATFORM_OS = BSD
        endif
        ifeq ($(UNAMEOS),DragonFly)
            PLATFORM_OS = BSD
        endif
        ifeq ($(UNAMEOS),Darwin)
            PLATFORM_OS = OSX
        endif
        ifndef PLATFORM_SHELL
            PLATFORM_SHELL = sh
        endif
    endif
endif
ifeq ($(PLATFORM),PLATFORM_RPI)
    UNAMEOS = $(shell uname)
    ifeq ($(UNAMEOS),Linux)
        PLATFORM_OS = LINUX
    endif
    ifndef PLATFORM_SHELL
        PLATFORM_SHELL = sh
    endif
endif
ifeq ($(PLATFORM),PLATFORM_DRM)
    UNAMEOS = $(shell uname)
    ifeq ($(UNAMEOS),Linux)
        PLATFORM_OS = LINUX
    endif
    ifndef PLATFORM_SHELL
        PLATFORM_SHELL = sh
    endif
endif
ifeq ($(PLATFORM),PLATFORM_WEB)
    ifeq ($(OS),Windows_NT)
        PLATFORM_OS = WINDOWS
        ifndef PLATFORM_SHELL
            PLATFORM_SHELL = cmd
        endif
    else
        UNAMEOS = $(shell uname)
        ifeq ($(UNAMEOS),Linux)
            PLATFORM_OS = LINUX
        endif
        ifndef PLATFORM_SHELL
            PLATFORM_SHELL = sh
        endif
    endif
endif

ifeq ($(PLATFORM),PLATFORM_WEB)
    # Emscripten required variables
    EMSDK_PATH         ?= C:/emsdk
    EMSCRIPTEN_PATH    ?= $(EMSDK_PATH)/upstream/emscripten
    CLANG_PATH          = $(EMSDK_PATH)/upstream/bin
    PYTHON_PATH         = $(EMSDK_PATH)/python/3.9.2-1_64bit
    NODE_PATH           = $(EMSDK_PATH)/node/14.15.5_64bit/bin
    export PATH         = $(EMSDK_PATH);$(EMSCRIPTEN_PATH);$(CLANG_PATH);$(NODE_PATH);$(PYTHON_PATH);C:\raylib\MinGW\bin:$$(PATH)
endif

ifeq ($(PLATFORM),PLATFORM_ANDROID)
    # Android architecture
    # Starting at 2019 using arm64 is mandatory for published apps,
    # Starting on August 2020, minimum required target API is Android 10 (API level 29)
    ANDROID_ARCH ?= arm64
    ANDROID_API_VERSION ?= 29

    # Android required path variables
    # NOTE: Starting with Android NDK r21, no more toolchain generation is required, NDK is the toolchain on itself
    ifeq ($(OS),Windows_NT)
        ANDROID_NDK ?= C:/android-ndk
        ANDROID_TOOLCHAIN = $(ANDROID_NDK)/toolchains/llvm/prebuilt/windows-x86_64
    else
        ANDROID_NDK ?= /usr/lib/android/ndk
        ANDROID_TOOLCHAIN = $(ANDROID_NDK)/toolchains/llvm/prebuilt/linux-x86_64
    endif

    # NOTE: Sysroot can also be reference from $(ANDROID_NDK)/sysroot
    ANDROID_SYSROOT ?= $(ANDROID_TOOLCHAIN)/sysroot

    ifeq ($(ANDROID_ARCH),arm)
        ANDROID_COMPILER_ARCH = armv7a
    endif
    ifeq ($(ANDROID_ARCH),arm64)
        ANDROID_COMPILER_ARCH = aarch64
    endif
    ifeq ($(ANDROID_ARCH),x86)
        ANDROID_COMPILER_ARCH = i686
    endif
    ifeq ($(ANDROID_ARCH),x86_64)
        ANDROID_COMPILER_ARCH = x86_64
    endif

endif

# Define raylib graphics api depending on selected platform
ifeq ($(PLATFORM),PLATFORM_DESKTOP)
    # By default use OpenGL 3.3 on desktop platforms
    GRAPHICS ?= GRAPHICS_API_OPENGL_33
    #GRAPHICS = GRAPHICS_API_OPENGL_11  # Uncomment to use OpenGL 1.1
    #GRAPHICS = GRAPHICS_API_OPENGL_21  # Uncomment to use OpenGL 2.1
endif
ifeq ($(PLATFORM),PLATFORM_RPI)
    # On RPI OpenGL ES 2.0 must be used
    GRAPHICS = GRAPHICS_API_OPENGL_ES2
endif
ifeq ($(PLATFORM),PLATFORM_DRM)
    # On DRM OpenGL ES 2.0 must be used
    GRAPHICS = GRAPHICS_API_OPENGL_ES2
endif
ifeq ($(PLATFORM),PLATFORM_WEB)
    # On HTML5 OpenGL ES 2.0 is used, emscripten translates it to WebGL 1.0
    GRAPHICS = GRAPHICS_API_OPENGL_ES2
endif
ifeq ($(PLATFORM),PLATFORM_ANDROID)
    # By default use OpenGL ES 2.0 on Android
    GRAPHICS = GRAPHICS_API_OPENGL_ES2
endif

# Define default C compiler and compiledb.
CC:=gcc
COMPILEDB:=compiledb

ifeq ($(PLATFORM),PLATFORM_DESKTOP)
    ifeq ($(PLATFORM_OS),OSX)
        # OSX default compiler
        CC = clang
        GLFW_OSX = -x objective-c
    endif
    ifeq ($(PLATFORM_OS),BSD)
        # FreeBSD, OpenBSD, NetBSD, DragonFly default compiler
        CC = clang
    endif
endif
ifeq ($(PLATFORM),PLATFORM_RPI)
    ifeq ($(USE_RPI_CROSS_COMPILER),TRUE)
        # Define RPI cross-compiler
        #CC = armv6j-hardfloatinux-gnueabi-gcc
        CC = $(RPI_TOOLCHAIN)/bin/arminux-gnueabihf-gcc
        AR = $(RPI_TOOLCHAIN)/bin/arminux-gnueabihf-ar
    endif
endif
ifeq ($(PLATFORM),PLATFORM_WEB)
    # HTML5 emscripten compiler
    CC = emcc
    AR = emar
endif
ifeq ($(PLATFORM),PLATFORM_ANDROID)
    # Android toolchain (must be provided for desired architecture and compiler)
    ifeq ($(ANDROID_ARCH),arm)
        CC = $(ANDROID_TOOLCHAIN)/bin/$(ANDROID_COMPILER_ARCH)inux-androideabi$(ANDROID_API_VERSION)-clang
    endif
    ifeq ($(ANDROID_ARCH),arm64)
        CC = $(ANDROID_TOOLCHAIN)/bin/$(ANDROID_COMPILER_ARCH)inux-android$(ANDROID_API_VERSION)-clang
    endif
    ifeq ($(ANDROID_ARCH),x86)
        CC = $(ANDROID_TOOLCHAIN)/bin/$(ANDROID_COMPILER_ARCH)inux-android$(ANDROID_API_VERSION)-clang
    endif
    ifeq ($(ANDROID_ARCH),x86_64)
        CC = $(ANDROID_TOOLCHAIN)/bin/$(ANDROID_COMPILER_ARCH)inux-android$(ANDROID_API_VERSION)-clang
    endif
    # It seems from Android NDK r22 onwards we need to use llvm-ar
    AR = $(ANDROID_TOOLCHAIN)/bin/llvm-ar
endif

# Define compiler flags: CFLAGS
#  -O1                      defines optimization level
#  -g                       include debug information on compilation
#  -s                       strip unnecessary data from build --> linker
#  -Wall                    turns on most, but not all, compiler warnings
#  -std=c99                 defines C language mode (standard C from 1999 revision)
#  -std=gnu99               defines C language mode (GNU C from 1999 revision)
#  -Wno-missing-braces      ignore invalid warning (GCC bug 53119)
#  -Werror=pointer-arith    catch unportable code that does direct arithmetic on void pointers
#  -fno-strict-aliasing     jar_xm.h does shady stuff (breaks strict aliasing)
CFLAGS = -Wall -D$(PLATFORM) -D$(GRAPHICS) -Wno-missing-braces -Werror=pointer-arith -fno-strict-aliasing $(CUSTOM_CFLAGS)

ifeq ($(PLATFORM), PLATFORM_WEB)
    # NOTE: When using multi-threading in the user code, it requires -pthread enabled
    CFLAGS += -std=gnu99
else
    CFLAGS += -std=c99
endif

ifeq ($(PLATFORM_OS), LINUX)
    CFLAGS += -fPIC
endif

ifeq ($(RAYLIB_BUILD_MODE),DEBUG)
    CFLAGS += -g -D_DEBUG
endif

ifeq ($(RAYLIB_BUILD_MODE),RELEASE)
    ifeq ($(PLATFORM),PLATFORM_WEB)
        CFLAGS += -Os
    endif
    ifeq ($(PLATFORM),PLATFORM_DESKTOP)
        CFLAGS += -O1
    endif
    ifeq ($(PLATFORM),PLATFORM_ANDROID)
        CFLAGS += -O2
    endif
endif

# Define directories.
GEN_DIR:=gen
DIST_DIR:=dist
CORE_DIR:=core
TOOL_DIR:=tool
3PARTY_DIR:=thirdparty
INCLUDE_DIRS:=$(3PARTY_DIR)/include $(CORE_DIR)

# Define additional directories containing required header files
ifeq ($(PLATFORM),PLATFORM_DESKTOP)
    ifeq ($(PLATFORM_OS),BSD)
        INCLUDE_DIRS += /usr/local/include
    endif
endif
ifeq ($(PLATFORM),PLATFORM_RPI)
    INCLUDE_DIRS += $(RPI_TOOLCHAIN_SYSROOT)/opt/vc/include
    INCLUDE_DIRS += $(RPI_TOOLCHAIN_SYSROOT)/opt/vc/include/interface/vmcs_host/linux
    INCLUDE_DIRS += $(RPI_TOOLCHAIN_SYSROOT)/opt/vc/include/interface/vcos/pthreads
endif
ifeq ($(PLATFORM),PLATFORM_DRM)
    INCLUDE_DIRS += /usr/include/libdrm
endif
ifeq ($(PLATFORM),PLATFORM_ANDROID)
    NATIVE_APP_GLUE = $(ANDROID_NDK)/sources/android/native_app_glue
    # Include android_native_app_glue.h
    INCLUDE_DIRS += $(NATIVE_APP_GLUE)

    # Android required libraries
    INCLUDE_DIRS += $(ANDROID_SYSROOT)/usr/include
    ifeq ($(ANDROID_ARCH),arm)
        INCLUDE_DIRS += $(ANDROID_SYSROOT)/usr/include/arminux-androideabi
    endif
    ifeq ($(ANDROID_ARCH),arm64)
        INCLUDE_DIRS += $(ANDROID_SYSROOT)/usr/include/aarch64inux-android
    endif
    ifeq ($(ANDROID_ARCH),x86)
        INCLUDE_DIRS += $(ANDROID_SYSROOT)/usr/include/i686inux-android
    endif
    ifeq ($(ANDROID_ARCH),x86_64)
        INCLUDE_DIRS += $(ANDROID_SYSROOT)/usr/include/x86_64inux-android
    endif
endif

# Define libraries required on linking: LINK_SHARED_LIBS
ifeq ($(PLATFORM),PLATFORM_DESKTOP)
    ifeq ($(PLATFORM_OS),WINDOWS)
        ifeq ($(CC), tcc)
            LINK_SHARED_LIBS = opengl32 gdi32 winmm shell32
        else
            LINK_SHARED_LIBS = -staticibgcc opengl32 gdi32 winmm
        endif
    endif
    ifeq ($(PLATFORM_OS),LINUX)
        LINK_SHARED_LIBS = GL c m pthread dl rt
        ifeq ($(USE_WAYLAND_DISPLAY),FALSE)
            LINK_SHARED_LIBS += X11
        endif
    endif
    ifeq ($(PLATFORM_OS),OSX)
        LINK_SHARED_LIBS = -framework OpenGL -framework Cocoa -framework IOKit -framework CoreAudio -framework CoreVideo
    endif
    ifeq ($(PLATFORM_OS),BSD)
        LINK_SHARED_LIBS = GL pthread
    endif
    ifeq ($(USE_EXTERNAL_GLFW),TRUE)
        # Check the version name. If GLFW3 was built manually, it may have produced
        # a static library known as libglfw3.a. In that case, the name should be glfw3
        LINK_SHARED_LIBS = glfw
    endif
endif
ifeq ($(PLATFORM),PLATFORM_RPI)
    LINK_SHARED_LIBS = brcmGLESv2 brcmEGL pthread rt m bcm_host dl
    ifeq ($(RAYLIB_MODULE_AUDIO),TRUE)
        LINK_SHARED_LIBS += atomic
    endif
endif
ifeq ($(PLATFORM),PLATFORM_DRM)
    LINK_SHARED_LIBS = GLESv2 EGL drm gbm pthread rt m dl
    ifeq ($(RAYLIB_MODULE_AUDIO),TRUE)
        LINK_SHARED_LIBS += atomic
    endif
endif
ifeq ($(PLATFORM),PLATFORM_ANDROID)
    LINK_SHARED_LIBS = log android EGL GLESv2 OpenSLES c m
endif

# Include directories.
CFLAGS+=$(INCLUDE_DIRS:%=-I%)

# Define core.
CORE_HEADERS:=$(wildcard $(CORE_DIR)/*.h)
CORE_SOURCES:=$(wildcard $(CORE_DIR)/*.c)
CORE_OBJECTS:=$(CORE_SOURCES:$(CORE_DIR)/%.c=$(GEN_DIR)/_CORE_%.o)

# Define tool.
TOOL_HEADERS:=$(wildcard $(TOOL_DIR)/*.h)
TOOL_SOURCES:=$(wildcard $(TOOL_DIR)/*.c)
TOOL_OBJECTS:=$(TOOL_SOURCES:$(TOOL_DIR)/%.c=$(GEN_DIR)/_TOOL_%.o)
TOOL_OUT:=$(DIST_DIR)/roki

3PARTY_STATIC_LIBS:=$(wildcard $(3PARTY_DIR)/lib/*)

default: setup-thirdparty compiledb $(TOOL_OUT)

.PHONY: \
	setup-thirdparty \
    clean \
	compiledb \
    default

compiledb:
	$(COMPILEDB) -n make

clean:
	rm -f $(CORE_OBJECTS) $(TOOL_OBJECTS) $(TOOL_OUT)

setup-thirdparty:
	$(MAKE) -C $(3PARTY_DIR)

clean-thirdparty:
	$(MAKE) -C $(3PARTY_DIR) clean

$(TOOL_OUT): $(TOOL_OBJECTS) $(CORE_OBJECTS)
	$(CC) $(CFLAGS) $^ $(3PARTY_STATIC_LIBS) -o $@ $(LINK_SHARED_LIBS:%=-l%) 

$(GEN_DIR)/_CORE_%.o: $(CORE_DIR)/%.c $(CORE_HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

$(GEN_DIR)/_TOOL_%.o: $(TOOL_DIR)/%.c $(TOOL_HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

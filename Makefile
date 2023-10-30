cc        := g++
name      := rknn
workdir   := workspace
srcdir    := src
objdir    := objs
stdcpp    := c++11


CFLAGS := -std=C++11 -LM =PTHREAD -fPIC -g -03 -fopenmp -w
CUFLAGS := -std=C++11 -Xcompiler -fPIC -g -03 -fopenmp -w 

# 定义cpp的路径查找和依赖项mk文件
cpp_srcs := $(shell find $(srcdir) -name "*.cpp")
cpp_objs := $(cpp_srcs:.cpp=.cpp.o)
cpp_objs := $(cpp_objs:$(srcdir)/%=$(objdir)/%)
cpp_mk   := $(cpp_objs:.cpp.o=.cpp.mk)

LOCAL_DIR	:= $(shell pwd)
$(info "[LOCAL_DIR]: $(LOCAL_DIR)") 


# 定义opencv和cuda需要用到的库文件
link_sys       := stdc++ dl pthread
link_opencv    := opencv_core opencv_imgproc opencv_imgcodecs opencv_video
link_librarys  := $(link_opencv) rknn_api rknnrt rga $(link_sys)

# cwd  := $(shell pwd)

# 定义头文件路径，请注意斜杠后边不能有空格
# 只需要写路径，不需要写-I


include_paths := src        \
    ${LOCAL_DIR}/librknn_api/include     \
	${LOCAL_DIR}/3rdparty/rga/RK3588/include \
	${LOCAL_DIR}/opencv-4.5.5/include

# 定义库文件路径，只需要写路径，不需要写-L
library_paths := ${cwd}/librknn_api/aarch64 \
		${LOCAL_DIR}/opencv-4.5.5/lib \
		${LOCAL_DIR}/3rdparty/rga/RK3588/lib/Linux/aarch64 \
		$(syslib)

# 把library path给拼接为一个字符串，例如a b c => a:b:c
# 然后使得LD_LIBRARY_PATH=a:b:c
empty := 
library_path_export := $(subst $(empty) $(empty),:,$(library_paths))

rknn    : workspace/rknn

# 把库路径和头文件路径拼接起来成一个，批量自动加-I、-L、-l
run_paths     := $(foreach item,$(library_paths),-Wl,-rpath=$(item))
include_paths := $(foreach item,$(include_paths),-I$(item))
library_paths := $(foreach item,$(library_paths),-L$(item))
link_librarys := $(foreach item,$(link_librarys),-l$(item))

cpp_compile_flags := -std=$(stdcpp) -w -g -O0 -fPIC -fopenmp -pthread

link_flags        := -pthread -fopenmp -Wl,-rpath='$$ORIGIN'

cpp_compile_flags += $(include_paths)

link_flags        += $(library_paths) $(link_librarys) $(run_paths)

# 如果头文件修改了，这里的指令可以让他自动编译依赖的cpp或者cu文件
ifneq ($(MAKECMDGOALS), clean)
-include $(cpp_mk) $(cu_mk)
endif

$(name)   : $(workdir)/$(name)

all       : $(name)
run       : $(name)
	@cd $(workdir) && ./$(name) $(run_args)

$(workdir)/$(name) : $(cpp_objs) $(cu_objs)
	@echo Link $@
	@mkdir -p $(dir $@)
	@$(cc) $^ -o $@ $(link_flags)

$(objdir)/%.cpp.o : $(srcdir)/%.cpp
	@echo Compile CXX $<
	@mkdir -p $(dir $@)
	@$(cc) -c $< -o $@ $(cpp_compile_flags)


# 编译cpp依赖项，生成mk文件
$(objdir)/%.cpp.mk : $(srcdir)/%.cpp
	@echo Compile depends C++ $<
	@mkdir -p $(dir $@)
	@$(cc) -M $< -MF $@ -MT $(@:.cpp.mk=.cpp.o) $(cpp_compile_flags)
    

# 定义清理指令
clean :
	@rm -rf $(objdir) $(workdir)/$(name)

# 防止符号被当做文件
.PHONY : clean run $(name)

# 导出依赖库路径，使得能够运行起来
export LD_LIBRARY_PATH:=$(library_path_export)
native_packages := native_ccache
ifeq ($(host_os),linux)
packages := zlib jansson
else
packages := zlib jansson  openssl libcurl
endif




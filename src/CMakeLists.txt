# sudo apt-get install libpcap-dev libnl-3-dev libnl-genl-3-dev
cmake_minimum_required(VERSION 3.0)

PROJECT(phantap C)
INCLUDE(GNUInstallDirs)
ADD_DEFINITIONS(-Wall -Werror --std=gnu99 -Wmissing-declarations)

if(NOT CMAKE_BUILD_TYPE OR CMAKE_BUILD_TYPE STREQUAL "None")
    set(CMAKE_BUILD_TYPE "RelWithDebInfo")
    message(STATUS "CMAKE_BUILD_TYPE is not set, set to default = ${CMAKE_BUILD_TYPE}")
endif()

message(STATUS "CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")

find_package(PkgConfig REQUIRED)
pkg_check_modules(PCAP REQUIRED libpcap)
pkg_check_modules(LIBNL REQUIRED libnl-3.0 libnl-genl-3.0)

ADD_EXECUTABLE(phantap-learn phantap-learn.c dhcp.c netlink.c)
TARGET_LINK_LIBRARIES(phantap-learn ${PCAP_LIBRARIES} ${LIBNL_LIBRARIES})
TARGET_INCLUDE_DIRECTORIES(phantap-learn PRIVATE ${PCAP_INCLUDE_DIRS} ${LIBNL_INCLUDE_DIRS})
INSTALL(TARGETS phantap-learn
    RUNTIME DESTINATION ${CMAKE_INSTALL_SBINDIR}
)

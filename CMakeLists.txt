cmake_minimum_required(VERSION 3.21)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
include(vcpkg_bootstrap)

project(lua-z3
  VERSION 0.1.0
  DESCRIPTION "Lua bindings for the Z3 theorem prover"
  LANGUAGES CXX
)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Find and include Targets library (provides cpp_library, cpp_binary, etc.)
find_package(Targets CONFIG REQUIRED)
include(Targets)

# Find dependencies
find_package(Lua REQUIRED)
find_package(luawrapper REQUIRED)
find_package(Z3 CONFIG REQUIRED)

# Import all source directories
import_all("${CMAKE_CURRENT_LIST_DIR}/Source")

# Installation
option(LUA_Z3_ENABLE_INSTALL "Enable installation rules" ON)
if(LUA_Z3_ENABLE_INSTALL)
  include(GNUInstallDirs)

  # Install the Lua module
  install(TARGETS z3
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/lua/5.4
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  )
endif()

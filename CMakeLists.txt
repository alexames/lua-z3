cmake_minimum_required(VERSION 3.21)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")

# Lua version selection (e.g. 5.1, 5.2, 5.3, 5.4, 5.5)
# Must be set before project() so vcpkg can resolve the correct dependency.
set(LUA_VERSION "5.5" CACHE STRING "Lua version to build against (5.1, 5.2, 5.3, 5.4, 5.5)")
set_property(CACHE LUA_VERSION PROPERTY STRINGS 5.1 5.2 5.3 5.4 5.5)

# Derive no-dot version string (e.g. "5.5" -> "55")
string(REPLACE "." "" LUA_VERSION_NODOT "${LUA_VERSION}")

# Configure vcpkg to install only the selected Lua version
set(VCPKG_MANIFEST_NO_DEFAULT_FEATURES ON)
set(VCPKG_MANIFEST_FEATURES "lua${LUA_VERSION_NODOT}" CACHE STRING "")

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
find_package(lua${LUA_VERSION_NODOT} CONFIG REQUIRED)
find_package(luawrapper REQUIRED)
find_package(Z3 CONFIG REQUIRED)

# Import all source directories
import_all("${CMAKE_CURRENT_LIST_DIR}/Source")

# Installation
option(LUA_Z3_ENABLE_INSTALL "Enable installation rules" ON)
if(LUA_Z3_ENABLE_INSTALL)
  include(GNUInstallDirs)

  # Install the Lua module
  install(TARGETS lua_z3
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/lua/${LUA_VERSION}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  )
endif()

cmake_minimum_required(VERSION 3.21)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")

# Lua version selection (e.g. 51, 52, 53, 54, 55)
# Must be set before project() so vcpkg can resolve the correct dependency.
set(LUA_VERSION "55" CACHE STRING "Lua version to build against (51, 52, 53, 54, 55)")
set_property(CACHE LUA_VERSION PROPERTY STRINGS 51 52 53 54 55)

# Derive dotted version string (e.g. "55" -> "5.5")
string(SUBSTRING "${LUA_VERSION}" 0 1 LUA_VERSION_MAJOR)
string(SUBSTRING "${LUA_VERSION}" 1 1 LUA_VERSION_MINOR)
set(LUA_VERSION_DOT "${LUA_VERSION_MAJOR}.${LUA_VERSION_MINOR}")

# Configure vcpkg to install only the selected Lua version
set(VCPKG_MANIFEST_NO_DEFAULT_FEATURES ON)
set(VCPKG_MANIFEST_FEATURES "lua${LUA_VERSION}" CACHE STRING "")

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
find_package(lua${LUA_VERSION} CONFIG REQUIRED)
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
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/lua/${LUA_VERSION_DOT}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  )
endif()

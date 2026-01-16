cpp_library(
  TARGET lua_z3
  TYPE SHARED
  SOURCES
    "LuaContext.cpp"
    "LuaSolver.cpp"
    "LuaExpr.cpp"
    "LuaSort.cpp"
    "LuaModel.cpp"
    "LuaZ3.cpp"
  DEPENDENCIES
    PUBLIC
      lua
      luawrapper::luawrapper
      z3::libz3
)

target_include_directories(lua_z3
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Include>
    $<INSTALL_INTERFACE:include>
)

# Set output name to just "z3" for Lua require("z3") to work
set_target_properties(lua_z3 PROPERTIES
  OUTPUT_NAME "z3"
  PREFIX ""
)

# On Windows, Lua modules need .dll extension
if(WIN32)
  set_target_properties(lua_z3 PROPERTIES SUFFIX ".dll")
endif()

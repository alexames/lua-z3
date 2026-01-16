cpp_library(
  TARGET z3
  TYPE SHARED
  SOURCES
    "LuaContext.cpp"
    "LuaSolver.cpp"
    "LuaExpr.cpp"
    "LuaSort.cpp"
    "LuaModel.cpp"
    "LuaZ3.cpp"
  DEPENDENCIES
    ${LUA_LIBRARIES}
    luawrapper::luawrapper
    z3::libz3
)

target_include_directories(z3
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Include>
    $<INSTALL_INTERFACE:include>
  PRIVATE
    ${LUA_INCLUDE_DIR}
)

# Set output name to just "z3" for Lua require to work
set_target_properties(z3 PROPERTIES
  OUTPUT_NAME "z3"
  PREFIX ""
)

# On Windows, Lua modules need .dll extension
if(WIN32)
  set_target_properties(z3 PROPERTIES SUFFIX ".dll")
endif()

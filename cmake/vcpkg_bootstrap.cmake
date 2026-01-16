include(FetchContent)

set(CMAKE_TOOLCHAIN_FILE "${FETCHCONTENT_BASE_DIR}/vcpkg-src/scripts/buildsystems/vcpkg.cmake"
  CACHE STRING "Vcpkg toolchain file")

FetchContent_Declare(
  "vcpkg"
  GIT_REPOSITORY "git@github.com:microsoft/vcpkg.git"
  GIT_TAG        "834977918592e4f5d5ec5fe48ba338c608faf9f9"
)

FetchContent_MakeAvailable("vcpkg")

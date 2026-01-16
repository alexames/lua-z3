vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alexames/lua-z3
  REF <COMMIT_HASH>
  SHA512 <SHA512>
  HEAD_REF main
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

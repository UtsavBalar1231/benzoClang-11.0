# CMake script that writes version control information to a header.
#
# Input variables:
#   NAMES             - A list of names for each of the source directories.
#   <NAME>_SOURCE_DIR - A path to source directory for each name in NAMES.
#   HEADER_FILE       - The header file to write
#
# The output header will contain macros <NAME>_REPOSITORY and <NAME>_REVISION,
# where "<NAME>" is substituted with the names specified in the input variables,
# for each of the <NAME>_SOURCE_DIR given.

get_filename_component(LLVM_CMAKE_DIR "${CMAKE_SCRIPT_MODE_FILE}" PATH)

list(APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")

include(VersionFromVCS)

# Handle strange terminals
set(ENV{TERM} "dumb")

function(append_info name path)
  if(path)
    get_source_info("${path}" revision repository)
  endif()
  set(TOOLCHAIN_REVISION "master")
  if(TOOLCHAIN_REVISION)
    file(APPEND "${HEADER_FILE}.tmp"
      "#define ${name}_REVISION \"${TOOLCHAIN_REVISION}\"\n")
  else()
    file(APPEND "${HEADER_FILE}.tmp"
      "#undef ${name}_REVISION\n")
  endif()
  set(TOOLCHAIN_REPOSITORY "https://github.com/benzoClang/llvm-project")
  if(TOOLCHAIN_REPOSITORY)
    file(APPEND "${HEADER_FILE}.tmp"
      "#define ${name}_REPOSITORY \"${TOOLCHAIN_REPOSITORY}\"\n")
  else()
    file(APPEND "${HEADER_FILE}.tmp"
      "#undef ${name}_REPOSITORY\n")
  endif()
endfunction()

foreach(name IN LISTS NAMES)
  if(NOT DEFINED ${name}_SOURCE_DIR)
    message(FATAL_ERROR "${name}_SOURCE_DIR is not defined")
  endif()
  append_info(${name} "${${name}_SOURCE_DIR}")
endforeach()

# Copy the file only if it has changed.
execute_process(COMMAND ${CMAKE_COMMAND} -E copy_if_different
  "${HEADER_FILE}.tmp" "${HEADER_FILE}")
file(REMOVE "${HEADER_FILE}.tmp")

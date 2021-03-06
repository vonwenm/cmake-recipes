find_package(Boost 1.61 QUIET COMPONENTS "${BOOST_COMPONENTS_REQUIRED}")
if(Boost_FOUND)
  message(STATUS "Found Boost version ${Boost_MAJOR_VERSION}.${Boost_MINOR_VERSION}.${Boost_SUBMINOR_VERSION}")
  add_library(boost_external INTERFACE)
else()
  message(STATUS "Suitable Boost could not be located, Building Boost instead.")

  if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    if(APPLE)
      set(toolset "darwin")
    else()
      set(toolset "gcc")
    endif()
  elseif(CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
    set(toolset "clang")
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "Intel")
    set(toolset "intel")
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    set(toolset "msvc")
  endif()

  if(WIN32)
    set(Boost_BOOTSTRAP "bootstrap.bat")
  else()
    set(Boost_BOOTSTRAP "bootstrap.sh")
  endif()

  # Non-empty list. Compiled libraries needed
  if(NOT "${BOOST_COMPONENTS_REQUIRED}" STREQUAL "")
    # Replace unit_test_framework (used by CMake's find_package) with test (understood by Boost build toolchain)
    string(REPLACE "unit_test_framework" "test" b2_needed_components "${BOOST_COMPONENTS_REQUIRED}")
    # Generate argument for BUILD_BYPRODUCTS
    set(_build_byproducts)
    foreach(_lib IN LISTS b2_needed_components)
      list(APPEND _build_byproducts ${DEPS_INSTALL_PREFIX}/boost/lib/libboost_${_lib}${CMAKE_SHARED_LIBRARY_SUFFIX})
    endforeach()
    # Transform the ;-separated list to a ,-separated list (digested by the Boost build toolchain!)
    string(REPLACE ";" "," b2_needed_components "${b2_needed_components}")
    set(select_libraries "--with-libraries=${b2_needed_components}")
    string(REPLACE ";" ", " printout "${BOOST_COMPONENTS_REQUIRED}")
    message(STATUS "  Libraries to be built: ${printout}")
  endif()

  set(Boost_USER_CONFIG_JAMFILE "${PROJECT_BINARY_DIR}/user-config.jam")
  file(WRITE "${Boost_USER_CONFIG_JAMFILE}" "using ${toolset} : : ${CMAKE_CXX_COMPILER} : <cxxflags>\"-std=c++11\" <linkflags>\"-std=c++11\" ;")
  set(Boost_BUILD_USER_CONFIG_ARGS "--user-config=${PROJECT_BINARY_DIR}/user-config.jam")

  include(ExternalProject)
  ExternalProject_Add(boost_external
    URL
      https://sourceforge.net/projects/boost/files/boost/1.61.0/boost_1_61_0.tar.gz
    URL_HASH
      SHA256=a77c7cc660ec02704c6884fbb20c552d52d60a18f26573c9cee0788bf00ed7e6
    DOWNLOAD_NO_PROGRESS
      1
    UPDATE_COMMAND
      ""
    CONFIGURE_COMMAND
      <SOURCE_DIR>/${Boost_BOOTSTRAP}
      --with-toolset=${toolset}
      --prefix=${DEPS_INSTALL_PREFIX}/boost
      ${select_libraries}
    BUILD_COMMAND
      <SOURCE_DIR>/b2 -q
           link=shared
           threading=multi
           variant=release
           toolset=${toolset}
           ${Boost_BUILD_USER_CONFIG_ARGS}
    BUILD_IN_SOURCE
      1
    INSTALL_COMMAND
      <SOURCE_DIR>/b2 -q install
           link=shared
           threading=multi
           variant=release
           toolset=${toolset}
           ${Boost_BUILD_USER_CONFIG_ARGS}
    LOG_BUILD
      1
    LOG_INSTALL
      1
    BUILD_BYPRODUCTS
      "${_build_byproducts}"
    )

  set(BOOST_ROOT ${DEPS_INSTALL_PREFIX}/boost
    CACHE PATH "Path to internally built Boost installation root" FORCE)
  set(BOOST_INCLUDEDIR ${BOOST_ROOT}/include
    CACHE PATH "Path to internally built Boost include directories" FORCE)
  set(BOOST_LIBRARYDIR ${BOOST_ROOT}/lib
    CACHE PATH "Path to internally built Boost library directories" FORCE)
endif()

add_library(buggy "")

target_sources(
  buggy
  PUBLIC
    ${CMAKE_CURRENT_LIST_DIR}/buggy.f90
  )

option(ENABLE_ASAN "Enable AddressSanitizer" OFF)

if(ENABLE_ASAN)
  if(CMAKE_Fortran_COMPILER_ID MATCHES GNU)
    target_compile_options(
      buggy
      PUBLIC
        -g -fsanitize=address
      )
    target_link_libraries(
      buggy
      PUBLIC
        asan
      )
  else()
    message(WARNING "AddressSanitizer not supported for this compiler")
  endif()
endif()

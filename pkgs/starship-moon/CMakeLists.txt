cmake_minimum_required(VERSION 4.0)
project(starship-moon LANGUAGES CXX C)

set(CMAKE_EXPORT_COMPILE_COMMANDS on)

  add_executable(starship-moon
      starship-moon.c
      lib/astronomy.c
      )

target_link_libraries(starship-moon PRIVATE m)

install(TARGETS starship-moon RUNTIME DESTINATION bin)

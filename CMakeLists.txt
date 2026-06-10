cmake_minimum_required(VERSION 3.20)
project(pairs_bumper)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(DEPENDENCIES
  rclcpp
  rclcpp_components
  cv_bridge
  geometry_msgs
  image_geometry
  image_transport
  pairs_lib
  pairs_msgs
  pcl_conversions
  pcl_msgs
  pcl_ros
  sensor_msgs
  tf2_geometry_msgs
  tf2_ros
  tf2_sensor_msgs
)

foreach(DEP IN LISTS DEPENDENCIES)
  find_package(${DEP} REQUIRED)
endforeach()

# set the compile options to show code warnings
if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra)
endif()

set(LIBRARIES
  PairsBumper_Bumper
  PairsBumper_HistogramDisplayer
)

## --------------------------------------------------------------
## |                            Build                           |
## --------------------------------------------------------------

function(add_pairs_library target source)
  add_library(${target} SHARED
    ${source}
  )

  ament_target_dependencies(${target}
    ${DEPENDENCIES}
  )

  target_include_directories(${target}
    PUBLIC
      $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
      $<INSTALL_INTERFACE:include>
  )
endfunction()

# bumper

add_pairs_library(
  PairsBumper_Bumper
  src/bumper_nodelet.cpp
)

rclcpp_components_register_node(PairsBumper_Bumper
  PLUGIN "pairs_bumper::Bumper"
  EXECUTABLE bumper
)

# histogram displayer

add_pairs_library(
  PairsBumper_HistogramDisplayer
  src/histogram_displayer.cpp
)

rclcpp_components_register_node(PairsBumper_HistogramDisplayer
  PLUGIN "pairs_bumper::HistogramDisplayer"
  EXECUTABLE histogram_displayer
)

## --------------------------------------------------------------
## |                           Install                          |
## --------------------------------------------------------------

install(TARGETS ${LIBRARIES} EXPORT export_${PROJECT_NAME}
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin
)

install(DIRECTORY launch config
  DESTINATION share/${PROJECT_NAME}
)

install(DIRECTORY tmux/
  USE_SOURCE_PERMISSIONS
  DESTINATION share/${PROJECT_NAME}/tmux
)

ament_export_targets(
  export_${PROJECT_NAME} HAS_LIBRARY_TARGET
)

ament_export_dependencies(
  ${DEPENDENCIES}
)

ament_package()

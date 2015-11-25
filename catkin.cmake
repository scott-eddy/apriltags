# Set up the ROS Catkin package settings.
find_package(catkin REQUIRED COMPONENTS
  cv_bridge
  std_msgs
  sensor_msgs
  image_transport
  roscpp
  cmake_modules
  message_generation
  geometry_msgs
)
find_package(OpenCV REQUIRED)
find_package(Eigen REQUIRED)

# Import the yaml-cpp libraries.
include(FindPkgConfig)
pkg_check_modules(Yaml REQUIRED yaml-cpp)

add_message_files(DIRECTORY msg FILES
    AprilTagDetection.msg
    AprilTagDetections.msg
)

generate_messages(DEPENDENCIES
    std_msgs
    geometry_msgs
)

# Set up the ROS Catkin package settings
catkin_package(
  INCLUDE_DIRS include
  CATKIN_DEPENDS cv_bridge
                 std_msgs
                 sensor_msgs
                 image_transport
                 roscpp
                 geometry_msgs
)

# CGAL requires that -frounding-math be set.
add_definitions(-frounding-math)

# Download the external apriltags-cpp repository.
include(ExternalProject)
ExternalProject_Add(apriltags-cpp
    DOWNLOAD_DIR ${PROJECT_SOURCE_DIR}
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/external/apriltags-cpp
    BINARY_DIR ${PROJECT_BINARY_DIR}/external/apriltags-cpp-build
    STAMP_DIR ${PROJECT_BINARY_DIR}/external/apriltags-cpp-stamp
    TMP_DIR ${PROJECT_BINARY_DIR}/external/apriltags-cpp-tmp
    INSTALL_COMMAND ""
    BUILD_COMMAND "make"
    CMAKE_ARGS -DCMAKE_CXX_FLAGS=-frounding-math -DBUILD_SHARED_LIBS:BOOL=ON
)

ExternalProject_Get_Property(apriltags-cpp SOURCE_DIR BINARY_DIR INSTALL_DIR)

message(STATUS "HEY YOU STUPID FUCK")
message(STATUS ${SOURCE_DIR})
# Tell CMake that the external project generated a library so we
# can add dependencies here instead of later.
set(apriltags_cpp_LIBRARIES
  "${BINARY_DIR}/libapriltags.so"
)

add_library(apriltags-cpp-libs UNKNOWN IMPORTED)
set_property(TARGET apriltags-cpp-libs
  PROPERTY IMPORTED_LOCATION
  ${apriltags_cpp_LIBRARIES}
)
add_dependencies(apriltags-cpp-libs apriltags-cpp)

include_directories(
    include/
    ${catkin_INCLUDE_DIRS}
    ${Eigen_INCLUDE_DIRS}
    ${OpenCV_INCLUDE_DIRS}
    ${Yaml_INCLUDE_DIRS}
    ${SOURCE_DIR}
)

add_executable(apriltags src/apriltags.cpp)
target_link_libraries(apriltags ${catkin_LIBRARIES})
target_link_libraries(apriltags ${Eigen_LIBRARIES})
target_link_libraries(apriltags ${OpenCV_LIBRARIES})
target_link_libraries(apriltags ${Yaml_LIBRARIES})
target_link_libraries(apriltags apriltags-cpp-libs)
add_dependencies(apriltags ${PROJECT_NAME}_gencpp)

install(TARGETS apriltags
  RUNTIME DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION} 
)

install(FILES ${apriltags_cpp_LIBRARIES}
  DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
)

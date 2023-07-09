# find the CycloneDDS library
message(STATUS "Find the CycloneDDS library")

find_library(CycloneDDS_LIBRARY NAMES ddsc)
find_path(CycloneDDS_INCLUDE_DIR NAMES ddsc/dds.h)

set(DDS_INCLUDE_DIRS "${CycloneDDS_INCLUDE_DIR}")
set(DDS_LIBRARIES ${CycloneDDS_LIBRARY})

if(NOT TARGET CycloneDDS::ddsc)
    if(TARGET "${CycloneDDS_LIBRARY}")
        # Alias if we found the config file
        add_library(CycloneDDS::ddsc ALIAS ddsc)
    else()
        add_library(CycloneDDS::ddsc UNKNOWN IMPORTED)
        set_target_properties(CycloneDDS::ddsc PROPERTIES 
            INTERFACE_INCLUDE_DIRECTORIES "${DDS_INCLUDE_DIRS}" 
            IMPORTED_LINK_INTERFACE_LANGUAGES "C" 
            IMPORTED_LOCATION "${DDS_LIBRARIES}")
    endif()
endif()

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(CycloneDDS
    REQUIRED_VARS DDS_LIBRARIES DDS_INCLUDE_DIRS)

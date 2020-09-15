# Find the DIA SDK path.
# It will typically look something like this:
# C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\DIA SDK\include

# CMAKE_GENERATOR_INSTANCE has the location of Visual Studio used
# i.e. C:/Program Files (x86)/Microsoft Visual Studio/2019/Community
set(VS_PATH ${CMAKE_GENERATOR_INSTANCE})
get_filename_component(VS_DIA_INC_PATH "${VS_PATH}/DIA SDK/include" ABSOLUTE CACHE)

# Starting in VS 15.2, vswhere is included.
# Unclear what the right component to search for is, might be Microsoft.VisualStudio.Component.VC.DiagnosticTools
# (although the friendly name of that is C++ profiling tools).  The toolset is the most likely target.
set(PROGRAMFILES_X86 "ProgramFiles(x86)")
execute_process(
  COMMAND "$ENV{${PROGRAMFILES_X86}}/Microsoft Visual Studio/Installer/vswhere.exe" -latest -prerelease -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
  OUTPUT_VARIABLE VSWHERE_LATEST
  ERROR_QUIET
  OUTPUT_STRIP_TRAILING_WHITESPACE
  )

# C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\DIA SDK\include
# C:\Program Files (x86)\Microsoft Visual Studio 14.0\DIA SDK\include
find_path(DIASDK_INCLUDE_DIR    # Set variable DIASDK_INCLUDE_DIR
          dia2.h                # Find a path with dia2.h
          HINTS "${VS_DIA_INC_PATH}"
          HINTS "${VSWHERE_LATEST}/DIA SDK/include"
          DOC "path to DIA SDK header files"
          )

if (CMAKE_GENERATOR MATCHES "Visual Studio.*Win64" )
  find_library(DIASDK_GUIDS_LIBRARY NAMES diaguids.lib
               HINTS ${DIASDK_INCLUDE_DIR}/../lib/amd64 )
elseif (CMAKE_GENERATOR MATCHES "Visual Studio.*ARM" )
  find_library(DIASDK_GUIDS_LIBRARY NAMES diaguids.lib
               HINTS ${DIASDK_INCLUDE_DIR}/../lib/arm )
else (CMAKE_GENERATOR MATCHES "Visual Studio.*Win64" )
  find_library(DIASDK_GUIDS_LIBRARY NAMES diaguids.lib
               HINTS ${DIASDK_INCLUDE_DIR}/../lib )
endif (CMAKE_GENERATOR MATCHES "Visual Studio.*Win64" )

set(DIASDK_LIBRARIES ${DIASDK_GUIDS_LIBRARY})
set(DIASDK_INCLUDE_DIRS ${DIASDK_INCLUDE_DIR})

include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set DIASDK_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(DiaSDK  DEFAULT_MSG
                                  DIASDK_LIBRARIES DIASDK_INCLUDE_DIR)

mark_as_advanced(DIASDK_INCLUDE_DIRS DIASDK_LIBRARIES)
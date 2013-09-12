
#-----------------------------------------------------------------------------
# Options for HDF5 Filters
#-----------------------------------------------------------------------------
MACRO (HDF5_SETUP_FILTERS FILTER)
  OPTION (HDF5_USE_FILTER_${FILTER} "Use the ${FILTER} Filter" ON)
  IF (HDF5_USE_FILTER_${FILTER})
    SET (H5_HAVE_FILTER_${FILTER} 1)
    SET (FILTERS "${FILTERS} ${FILTER}")
  ENDIF (HDF5_USE_FILTER_${FILTER})
  # MESSAGE (STATUS "Filter ${FILTER} is ${HDF5_USE_FILTER_${FILTER}}")
ENDMACRO (HDF5_SETUP_FILTERS)

HDF5_SETUP_FILTERS (SHUFFLE)
HDF5_SETUP_FILTERS (FLETCHER32)
HDF5_SETUP_FILTERS (NBIT)
HDF5_SETUP_FILTERS (SCALEOFFSET)

INCLUDE (ExternalProject)
OPTION (HDF5_ALLOW_EXTERNAL_SUPPORT "Allow External Library Building (NO SVN TGZ)" "NO")
IF (HDF5_ALLOW_EXTERNAL_SUPPORT MATCHES "SVN" OR HDF5_ALLOW_EXTERNAL_SUPPORT MATCHES "TGZ")
  OPTION (ZLIB_USE_EXTERNAL "Use External Library Building for ZLIB" 1)
  OPTION (SZIP_USE_EXTERNAL "Use External Library Building for SZIP" 1)
  IF (HDF5_ALLOW_EXTERNAL_SUPPORT MATCHES "SVN")
    SET (ZLIB_URL ${ZLIB_SVN_URL})
    SET (SZIP_URL ${SZIP_SVN_URL})
  ELSEIF (HDF5_ALLOW_EXTERNAL_SUPPORT MATCHES "TGZ")
    IF (NOT TGZPATH)
      SET (TGZPATH ${HDF5_SOURCE_DIR})
    ENDIF (NOT TGZPATH)
    SET (ZLIB_URL ${TGZPATH}/${ZLIB_TGZ_NAME})
    SET (SZIP_URL ${TGZPATH}/${SZIP_TGZ_NAME})
  ELSE (HDF5_ALLOW_EXTERNAL_SUPPORT MATCHES "SVN")
    SET (ZLIB_USE_EXTERNAL 0)
    SET (SZIP_USE_EXTERNAL 0)
  ENDIF (HDF5_ALLOW_EXTERNAL_SUPPORT MATCHES "SVN")
ENDIF (HDF5_ALLOW_EXTERNAL_SUPPORT MATCHES "SVN" OR HDF5_ALLOW_EXTERNAL_SUPPORT MATCHES "TGZ")

#-----------------------------------------------------------------------------
# Option for ZLib support
#-----------------------------------------------------------------------------
OPTION (HDF5_ENABLE_Z_LIB_SUPPORT "Enable Zlib Filters" OFF)
IF (HDF5_ENABLE_Z_LIB_SUPPORT)
  IF (NOT H5_ZLIB_HEADER)
    IF (NOT ZLIB_USE_EXTERNAL)
      FIND_PACKAGE (ZLIB NAMES ${ZLIB_PACKAGE_NAME}${HDF_PACKAGE_EXT})
      IF (NOT ZLIB_FOUND)
        FIND_PACKAGE (ZLIB) # Legacy find
      ENDIF (NOT ZLIB_FOUND)
    ENDIF (NOT ZLIB_USE_EXTERNAL)
    IF (ZLIB_FOUND)
      SET (H5_HAVE_FILTER_DEFLATE 1)
      SET (H5_HAVE_ZLIB_H 1)
      SET (H5_HAVE_LIBZ 1)
      SET (H5_ZLIB_HEADER "zlib.h")
      SET (ZLIB_INCLUDE_DIR_GEN ${ZLIB_INCLUDE_DIR})
      SET (ZLIB_INCLUDE_DIRS ${ZLIB_INCLUDE_DIR})
    ELSE (ZLIB_FOUND)
      IF (HDF5_ALLOW_EXTERNAL_SUPPORT MATCHES "SVN" OR HDF5_ALLOW_EXTERNAL_SUPPORT MATCHES "TGZ")
        EXTERNAL_ZLIB_LIBRARY (${HDF5_ALLOW_EXTERNAL_SUPPORT} ${LIB_TYPE})
        SET (H5_HAVE_FILTER_DEFLATE 1)
        SET (H5_HAVE_ZLIB_H 1)
        SET (H5_HAVE_LIBZ 1)
        MESSAGE (STATUS "Filter ZLIB is built")
      ELSE (HDF5_ALLOW_EXTERNAL_SUPPORT MATCHES "SVN" OR HDF5_ALLOW_EXTERNAL_SUPPORT MATCHES "TGZ")
        MESSAGE (FATAL_ERROR " ZLib is Required for ZLib support in HDF5")
      ENDIF (HDF5_ALLOW_EXTERNAL_SUPPORT MATCHES "SVN" OR HDF5_ALLOW_EXTERNAL_SUPPORT MATCHES "TGZ")
    ENDIF (ZLIB_FOUND)
  ELSE (NOT H5_ZLIB_HEADER)
    # This project is being called from within another and ZLib is already configured
    SET (H5_HAVE_FILTER_DEFLATE 1)
    SET (H5_HAVE_ZLIB_H 1)
    SET (H5_HAVE_LIBZ 1)
  ENDIF (NOT H5_ZLIB_HEADER)
  IF (H5_HAVE_FILTER_DEFLATE)
    SET (EXTERNAL_FILTERS "${EXTERNAL_FILTERS} DEFLATE")
  ENDIF (H5_HAVE_FILTER_DEFLATE)
  SET (LINK_LIBS ${LINK_LIBS} ${ZLIB_LIBRARIES})
  INCLUDE_DIRECTORIES (${ZLIB_INCLUDE_DIRS})
  MESSAGE (STATUS "Filter ZLIB is ON")
ENDIF (HDF5_ENABLE_Z_LIB_SUPPORT)

#-----------------------------------------------------------------------------
# Option for SzLib support
#-----------------------------------------------------------------------------
OPTION (HDF5_ENABLE_SZIP_SUPPORT "Use SZip Filter" OFF)
IF (HDF5_ENABLE_SZIP_SUPPORT)
  OPTION (HDF5_ENABLE_SZIP_ENCODING "Use SZip Encoding" OFF)
  IF (NOT SZIP_USE_EXTERNAL)
    FIND_PACKAGE (SZIP NAMES ${SZIP_PACKAGE_NAME}${HDF_PACKAGE_EXT})
    IF (NOT SZIP_FOUND)
      FIND_PACKAGE (SZIP) # Legacy find
    ENDIF (NOT SZIP_FOUND)
  ENDIF (NOT SZIP_USE_EXTERNAL)
  IF (SZIP_FOUND)
    SET (H5_HAVE_FILTER_SZIP 1)
    SET (H5_HAVE_SZLIB_H 1)
    SET (H5_HAVE_LIBSZ 1)
    SET (SZIP_INCLUDE_DIR_GEN ${SZIP_INCLUDE_DIR})
    SET (SZIP_INCLUDE_DIRS ${SZIP_INCLUDE_DIR})
  ELSE (SZIP_FOUND)
    IF (HDF5_ALLOW_EXTERNAL_SUPPORT MATCHES "SVN" OR HDF5_ALLOW_EXTERNAL_SUPPORT MATCHES "TGZ")
      EXTERNAL_SZIP_LIBRARY (${HDF5_ALLOW_EXTERNAL_SUPPORT} ${LIB_TYPE} ${HDF5_ENABLE_SZIP_ENCODING})
      SET (H5_HAVE_FILTER_SZIP 1)
      SET (H5_HAVE_SZLIB_H 1)
      SET (H5_HAVE_LIBSZ 1)
      MESSAGE (STATUS "Filter SZIP is built")
    ELSE (HDF5_ALLOW_EXTERNAL_SUPPORT MATCHES "SVN" OR HDF5_ALLOW_EXTERNAL_SUPPORT MATCHES "TGZ")
      MESSAGE (FATAL_ERROR "SZIP is Required for SZIP support in HDF5")
    ENDIF (HDF5_ALLOW_EXTERNAL_SUPPORT MATCHES "SVN" OR HDF5_ALLOW_EXTERNAL_SUPPORT MATCHES "TGZ")
  ENDIF (SZIP_FOUND)
  SET (LINK_LIBS ${LINK_LIBS} ${SZIP_LIBRARIES})
  INCLUDE_DIRECTORIES (${SZIP_INCLUDE_DIR})
  MESSAGE (STATUS "Filter SZIP is ON")
  IF (H5_HAVE_FILTER_SZIP)
    SET (EXTERNAL_FILTERS "${EXTERNAL_FILTERS} DECODE")
  ENDIF (H5_HAVE_FILTER_SZIP)
  IF (HDF5_ENABLE_SZIP_ENCODING)
    SET (H5_HAVE_SZIP_ENCODER 1)
    SET (EXTERNAL_FILTERS "${EXTERNAL_FILTERS} ENCODE")
  ENDIF (HDF5_ENABLE_SZIP_ENCODING)
ENDIF (HDF5_ENABLE_SZIP_SUPPORT)

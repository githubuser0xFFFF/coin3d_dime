#! /bin/sh
# **************************************************************************
# This is a hack for generating a Microsoft Developer Studio project and
# workspace files (.dsp/.dsw) for building Coin from the MSVC++ IDE.  It
# hooks into the Automake process as a fake compiler, building the project
# file instead of the sources.
#
# TODO:
#  - Defines should be verified:
#     are WIN32 and _WINDOWS necessary?
#     should _DEBUG be defined?
#  - Wtf is "Package Owner <4>"?  Want this to mean SIM if possible :),
#    not MS if <4> is some code for that...
#  - Indicate that the dsp file is *not* generated by Microsoft Developer
#    Studio?  Will the MSVC++ IDE eat "foreign" dsp files?
#  - Ensure that thammer and preng put me in their wills...
#
#    20030220 larsa
#
# NOTES
# * The large blocks of text were originally written as "cat >file <<EOF"
#   blocks, but for some reason I still don't understand, that did not
#   produce any input to file in the case of SoWin on Cygwin.  It worked
#   for other cases.  It therefore had to be obfuscated into large
#   echo "" >file blocks so it would work universally for all the projects.

me=$0
# run this where needed: me=`echo $me | sed 's%^.*/%%g'`

if test x"$1" = x"--register-public-header"; then
  # sourcedir=$2
  # builddir=$3
  studiofile=$4
  headerfile=$5
  # installpath=`CYGWIN= cygpath -w "$6" 2>/dev/null || echo "$6"`

  case $headerfile in
  [a-z]:* | /* )
    # absolute path
    ;;
  * )
    # relative path
    headerfile="`pwd`/$headerfile"
    ;;
  esac
  headerfile=`CYGWIN= cygpath -w "$headerfile" 2>/dev/null || echo "$headerfile"`
  echo "# Begin Source File" >>"$studiofile"
  echo "" >>"$studiofile"
  echo "SOURCE=$headerfile" >>"$studiofile"
  echo "# End Source File" >>"$studiofile"
  exit 0
fi

# this variable should contain the list of variables we want to use in the
# project file setup, instead of just having the values.

reversevars="QTDIR COINDIR"

sourcefile=
objectfile=
dependfile=
studiofile=
outputfile=

LIBRARY=
library=
Library=

for arg
do
  if test x"$outputfile" = x"next"; then
    outputfile=$arg
  else
    case $arg in
    -c )
      # -c only means _compile_ some file, not that the source file is
      # the next argument, hence we need to do it differently than for
      # the -o option
      sourcefile=get
      ;;
    -o ) outputfile=next ;;
    -MF | -MD | -MP )
      # haven't investigated if one of these are defined to be last
      # before the dep-file, so i've done it this way.
      dependfile=get
      ;;
    -Wp,-MD,* )
      dependfile=`echo $arg | cut -c9-`
      ;;
    -D*_INTERNAL )
      LIBRARY=`echo $arg | cut -d_ -f1 | cut -c3-`
      library=`echo $LIBRARY | tr A-Z a-z`
      case $library in
      coin ) Library=Coin ;;
      soqt ) Library=SoQt ;;
      sowin ) Library=SoWin ;;
      * ) Library=$library ;;
      esac
      ;;
    -Ddspfile=* | -Wl,-Ddspfile=* )
      # the build system is hacked to pass us the path to the .dsp file
      # this way.
      studiofile=`echo $arg | cut -d= -f2-`
      # FIXME: we don't get the -D*_INTERNAL flag when closing, so we
      # have to set up the variables here too.
      library=`echo "$studiofile" | sed -e 's%.*[\\/]%%g' -e 's%[0-9].*$%%'`
      LIBRARY=`echo $library | tr a-z A-Z`
      case $library in
      coin ) Library=Coin ;;
      soqt ) Library=SoQt ;;
      sowin ) Library=SoWin ;;
      * ) Library=$library ;;
      esac
      ;;
    -* )
      ;;
    * )
      if test x"$sourcefile" = x"get"; then
        sourcefile=$arg
      elif test x"$dependfile" = x"get"; then
        dependfile=$arg
      fi
      ;;
    esac
  fi
done

if test x"$studiofile" = x""; then
  exit 0
fi

if test x"$sourcefile" = x""; then :; else
  if test x"$objectfile" = x""; then
    objectfile=`echo $sourcefile | sed -e 's%^.*[/\\\\]%%g' -e 's%\.\(cpp\|c\)$%.o%'`
  fi
fi

if test x"$objectfile" = x""; then :; else
  date >$objectfile
fi

if test x"$dependfile" = x""; then :; else
  echo "" >$dependfile
fi

if test -f "$studiofile"; then :; else
  # file does not exist yet
  echo "# Microsoft Developer Studio Project File - Name=\"${library}@${LIBRARY}_MAJOR_VERSION@\" - Package Owner=<4>" >>"$studiofile"
  echo "# Microsoft Developer Studio Generated Build File, Format Version 6.00" >>"$studiofile"
  echo "# ** DO NOT EDIT **" >>"$studiofile"
  echo "" >>"$studiofile"
  echo "# TARGTYPE \"Win32 (x86) Dynamic-Link Library\" 0x0102" >>"$studiofile"
  echo "" >>"$studiofile"
  echo "CFG=${library}@${LIBRARY}_MAJOR_VERSION@ - Win32 Debug" >>"$studiofile"
  echo "!MESSAGE This is not a valid makefile. To build this project using NMAKE," >>"$studiofile"
  echo "!MESSAGE use the Export Makefile command and run" >>"$studiofile"
  echo "!MESSAGE" >>"$studiofile"
  echo "!MESSAGE NMAKE /f \"${library}@${LIBRARY}_MAJOR_VERSION@.mak\"." >>"$studiofile"
  echo "!MESSAGE" >>"$studiofile"
  echo "!MESSAGE You can specify a configuration when running NMAKE" >>"$studiofile"
  echo "!MESSAGE by defining the macro CFG on the command line. For example:" >>"$studiofile"
  echo "!MESSAGE" >>"$studiofile"
  echo "!MESSAGE NMAKE /f \"${library}@${LIBRARY}_MAJOR_VERSION@.mak\" CFG=\"${library}@${LIBRARY}_MAJOR_VERSION@d - Win32 Debug\"" >>"$studiofile"
  echo "!MESSAGE" >>"$studiofile"
  echo "!MESSAGE Possible choices for configuration are:" >>"$studiofile"
  echo "!MESSAGE" >>"$studiofile"
  echo "!MESSAGE \"${library}@${LIBRARY}_MAJOR_VERSION@ - Win32 Release\" (based on \"Win32 (x86) Dynamic-Link Library\")" >>"$studiofile"
  echo "!MESSAGE \"${library}@${LIBRARY}_MAJOR_VERSION@ - Win32 Debug\" (based on \"Win32 (x86) Dynamic-Link Library\")" >>"$studiofile"
  echo "!MESSAGE" >>"$studiofile"
  echo "" >>"$studiofile"
  echo "# Begin Project" >>"$studiofile"
  echo "# PROP AllowPerConfigDependencies 0" >>"$studiofile"
  echo "# PROP Scc_ProjName \"\"" >>"$studiofile"
  echo "# PROP Scc_LocalPath \"\"" >>"$studiofile"
  echo "CPP=cl.exe" >>"$studiofile"
  echo "MTL=midl.exe" >>"$studiofile"
  echo "RSC=rc.exe" >>"$studiofile"
  echo "" >>"$studiofile"
  echo "!IF  \"\$(CFG)\" == \"${library}@${LIBRARY}_MAJOR_VERSION@ - Win32 Release\"" >>"$studiofile"
  echo "" >>"$studiofile"
  echo "# PROP BASE Use_MFC 0" >>"$studiofile"
  echo "# PROP BASE Use_Debug_Libraries 0" >>"$studiofile"
  echo "# PROP BASE Output_Dir \"Release\"" >>"$studiofile"
  echo "# PROP BASE Intermediate_Dir \"Release\"" >>"$studiofile"
  echo "# PROP BASE Target_Dir \"\"" >>"$studiofile"
  echo "# PROP Use_MFC 0" >>"$studiofile"
  echo "# PROP Use_Debug_Libraries 0" >>"$studiofile"
  echo "# PROP Output_Dir \"Release\"" >>"$studiofile"
  echo "# PROP Intermediate_Dir \"Release\"" >>"$studiofile"
  echo "# PROP Ignore_Export_Lib 0" >>"$studiofile"
  echo "# PROP Target_Dir \"\"" >>"$studiofile"
  echo "# ADD BASE CPP /nologo /MD /W3 /GX /O2 /D \"WIN32\" /D \"NDEBUG\" /D \"_WINDOWS\" /D \"${LIBRARY}_DEBUG=0\" @${LIBRARY}_DSP_DEFS@ @${LIBRARY}_DSP_INCS@ /YX /FD /c" >>"$studiofile"
  echo "# ADD CPP /nologo /MD /W3 /GX /O1 /D \"WIN32\" /D \"NDEBUG\" /D \"_WINDOWS\" /D \"${LIBRARY}_DEBUG=0\" @${LIBRARY}_DSP_DEFS@ @${LIBRARY}_DSP_INCS@ /YX /FD /c" >>"$studiofile"
  echo "# ADD BASE MTL /nologo /D \"NDEBUG\" /mktyplib203 /win32" >>"$studiofile"
  echo "# ADD MTL /nologo /D \"NDEBUG\" /mktyplib203 /win32" >>"$studiofile"
  echo "# ADD BASE RSC /l 0x409 /d \"NDEBUG\"" >>"$studiofile"
  echo "# ADD RSC /l 0x409 /d \"NDEBUG\"" >>"$studiofile"
  echo "BSC32=bscmake.exe" >>"$studiofile"
  echo "# ADD BASE BSC32 /nologo" >>"$studiofile"
  echo "# ADD BSC32 /nologo" >>"$studiofile"
  echo "LINK32=link.exe" >>"$studiofile"
  echo "# ADD BASE LINK32 @${LIBRARY}_DSP_LIBS@ /nologo /dll /machine:I386" >>"$studiofile"
  echo "# ADD LINK32 @${LIBRARY}_DSP_LIBS@ /nologo /dll /machine:I386 /out:\"${library}@${LIBRARY}_MAJOR_VERSION@.dll\" /opt:nowin98" >>"$studiofile"
  echo "# SUBTRACT LINK32 /pdb:none" >>"$studiofile"
  echo "" >>"$studiofile"

  echo "!ELSEIF  \"\$(CFG)\" == \"${library}@${LIBRARY}_MAJOR_VERSION@ - Win32 Debug\"" >>"$studiofile"
  echo "" >>"$studiofile"
  echo "# PROP BASE Use_MFC 0" >>"$studiofile"
  echo "# PROP BASE Use_Debug_Libraries 1" >>"$studiofile"
  echo "# PROP BASE Output_Dir \"Debug\"" >>"$studiofile"
  echo "# PROP BASE Intermediate_Dir \"Debug\"" >>"$studiofile"
  echo "# PROP BASE Target_Dir \"\"" >>"$studiofile"
  echo "# PROP Use_MFC 0" >>"$studiofile"
  echo "# PROP Use_Debug_Libraries 1" >>"$studiofile"
  echo "# PROP Output_Dir \"Debug\"" >>"$studiofile"
  echo "# PROP Intermediate_Dir \"Debug\"" >>"$studiofile"
  echo "# PROP Target_Dir \"\"" >>"$studiofile"
  echo "# ADD BASE CPP /nologo /MDd /W3 /Gm /GX /ZI /Od /D \"WIN32\" /D \"_DEBUG\" /D \"_WINDOWS\" /D \"${LIBRARY}_DEBUG=1\" @${LIBRARY}_DSP_DEFS@ @${LIBRARY}_DSP_INCS@ /YX /FD /GZ /c" >>"$studiofile"
  echo "# ADD CPP /nologo /MDd /W3 /Gm /GX /ZI /Od /D \"WIN32\" /D \"_DEBUG\" /D \"_WINDOWS\" /D \"${LIBRARY}_DEBUG=1\" @${LIBRARY}_DSP_DEFS@ @${LIBRARY}_DSP_INCS@ /YX /FD /GZ /c" >>"$studiofile"
  echo "# ADD BASE MTL /nologo /D \"_DEBUG\" /mktyplib203 /win32" >>"$studiofile"
  echo "# ADD MTL /nologo /D \"_DEBUG\" /mktyplib203 /win32" >>"$studiofile"
  echo "# ADD BASE RSC /l 0x409 /d \"_DEBUG\"" >>"$studiofile"
  echo "# ADD RSC /l 0x409 /d \"_DEBUG\"" >>"$studiofile"
  echo "BSC32=bscmake.exe" >>"$studiofile"
  echo "# ADD BASE BSC32 /nologo" >>"$studiofile"
  echo "# ADD BSC32 /nologo" >>"$studiofile"
  echo "LINK32=link.exe" >>"$studiofile"
  echo "# ADD BASE LINK32 @${LIBRARY}_DSP_LIBS@ /nologo /dll /debug /machine:I386 /pdbtype:sept" >>"$studiofile"
  echo "# ADD LINK32 @${LIBRARY}_DSP_LIBS@ /nologo /dll /debug /machine:I386 /pdbtype:sept /out:\"${library}@${LIBRARY}_MAJOR_VERSION@d.dll\"" >>"$studiofile"
  echo "" >>"$studiofile"
  echo "!ENDIF" >>"$studiofile"
  echo "" >>"$studiofile"
  echo "# Begin Target" >>"$studiofile"
  echo "" >>"$studiofile"
  echo "# Name \"${library}@${LIBRARY}_MAJOR_VERSION@ - Win32 Release\"" >>"$studiofile"
  echo "# Name \"${library}@${LIBRARY}_MAJOR_VERSION@ - Win32 Debug\"" >>"$studiofile"
  echo "# Begin Group \"Source Files\"" >>"$studiofile"
  echo "" >>"$studiofile"
  echo "# PROP Default_Filter \"cpp;c;ic;icc\"" >>"$studiofile"
fi

if test `grep -c "# End Project" "$studiofile"` -gt 0; then
  me=`echo $me | sed 's%^.*/%%g'`
  echo >&2 "$me: error: project file is closed - you must start from scratch (make clean)"
  exit 1
fi

if test x"$sourcefile" = x""; then :; else
  # set up section for the source file
  case $sourcefile in
  [a-zA-Z]:* | /* ) ;;
  * )
    # this is a relative path
    sourcefile="`pwd`/$sourcefile"
    ;;
  esac
  echo "# Begin Source File" >>"$studiofile"
  echo "" >>"$studiofile"
  sourcefile=`CYGWIN= cygpath -w "$sourcefile" 2>/dev/null || echo "$sourcefile"`
  echo "SOURCE=$sourcefile" >>"$studiofile"
  echo "# End Source File" >>"$studiofile"
fi

case "$outputfile" in
*.so.* )
  # this is how we detect the last command in the build process
  date >>"$outputfile"
  # "close" the dsp file
  echo '# End Group' >>"$studiofile"

  # We need to know about the root build dir and source dir to trigger the
  # header installation rule, and to locate the additional source files we
  # should put in the .dsp file
  builddir=`echo "$studiofile" | sed -e 's%/[^/]*$%%'`
  builddir_unix=$builddir
  builddir=`CYGWIN= cygpath -w "$builddir" 2>/dev/null || echo "$builddir"`

  sourcedir=`echo "$0" | sed -e 's%/cfg/m4/gendsp.sh$%%'`
  sourcedir_unix=$sourcedir
  sourcedir=`CYGWIN= cygpath -w "$sourcedir" 2>/dev/null || echo "$sourcedir"`

  # PUBLIC HEADERS
  # To get the list of public header files, we run "make install" into a
  # temporary directory, while overriding the header-install program to be
  # this script with a magic option as the first argument.  Afterwards we
  # clean out the temporary install dir.
  echo '# Begin Group "Public Headers"' >>"$studiofile"
  echo "" >>"$studiofile"
  echo '# PROP Default_Filter "h"' >>"$studiofile"
  ( cd $builddir_unix; make INSTALL_HEADER="$0 --register-public-header $sourcedir $builddir $studiofile" DESTDIR=/tmp/coin-dsp install-data )
  rm -rf /tmp/coin-dsp
  echo '# End Group' >>"$studiofile"

  # PRIVATE HEADERS
  # I don't know how to properly construct a list of private headers yet,
  # but we can for sure assume that all .ic/.icc source files are includes
  # used from other source files.  We also assume that header files that
  # check for <lib>_INTERNAL and emits a #error with a message containing
  # "private" or "internal" is an internal header file.
  echo '# Begin Group "Private Headers"' >>"$studiofile"
  echo "" >>"$studiofile"
  echo '# PROP Default_Filter "h;ic;icc"' >>"$studiofile"
  for file in `find $sourcedir_unix $builddir_unix -name "*.h" | xargs grep -l "_INTERNAL\$" | xargs grep -i -l "#error.*private"`; do
    echo "# Begin Source File" >>"$studiofile"
    echo "" >>"$studiofile"
    filepath=`CYGWIN= cygpath -w "$file" 2>/dev/null || echo "$file"`
    echo "SOURCE=$filepath" >>"$studiofile"
    echo "# PROP Exclude_From_Build 1" >>"$studiofile"
    echo "# End Source File" >>"$studiofile"
  done
  for file in `find $sourcedir_unix $builddir_unix -name "*.ic" -o -name "*.icc"`; do
    echo "# Begin Source File" >>"$studiofile"
    echo "" >>"$studiofile"
    filepath=`CYGWIN= cygpath -w "$file" 2>/dev/null || echo "$file"`
    echo "SOURCE=$filepath" >>"$studiofile"
    echo "# PROP Exclude_From_Build 1" >>"$studiofile"
    echo "# End Source File" >>"$studiofile"
  done
  echo '# End Group' >>"$studiofile"
  # close the .dsp file
  echo '# End Target' >>"$studiofile"
  echo '# End Project' >>"$studiofile"

  # create the .dsw file
  workspacefile=`echo "$studiofile" | sed 's/\.dsp/.dsw/'`
  echo "Microsoft Developer Studio Workspace File, Format Version 6.00" >>"$workspacefile.in"
  echo "# WARNING: DO NOT EDIT OR DELETE THIS WORKSPACE FILE!" >>"$workspacefile.in"
  echo "" >>"$workspacefile.in"
  echo "###############################################################################" >>"$workspacefile.in"
  echo "" >>"$workspacefile.in"
  echo "Project: \"${library}@${LIBRARY}_MAJOR_VERSION@\"=.\\${library}@${LIBRARY}_MAJOR_VERSION@.dsp - Package Owner=<4>" >>"$workspacefile.in"
  echo "" >>"$workspacefile.in"
  echo "Package=<5>" >>"$workspacefile.in"
  echo "{{{" >>"$workspacefile.in"
  echo "}}}" >>"$workspacefile.in"
  echo "" >>"$workspacefile.in"
  echo "Package=<4>" >>"$workspacefile.in"
  echo "{{{" >>"$workspacefile.in"
  echo "}}}" >>"$workspacefile.in"
  echo "" >>"$workspacefile.in"
  echo "###############################################################################" >>"$workspacefile.in"
  echo "" >>"$workspacefile.in"
  echo "Global:" >>"$workspacefile.in"
  echo "" >>"$workspacefile.in"
  echo "Package=<5>" >>"$workspacefile.in"
  echo "{{{" >>"$workspacefile.in"
  echo "}}}" >>"$workspacefile.in"
  echo "" >>"$workspacefile.in"
  echo "Package=<3>" >>"$workspacefile.in"
  echo "{{{" >>"$workspacefile.in"
  echo "}}}" >>"$workspacefile.in"
  echo "" >>"$workspacefile.in"
  echo "###############################################################################" >>"$workspacefile.in"
  echo "" >>"$workspacefile.in"

  # Make everything peachy for MS DOS

  mv "$studiofile" "$studiofile.in2"
  ( cd "$builddir_unix"; ./config.status --file="-:-" <"$workspacefile.in" >"$workspacefile.txt" )
  ( cd "$builddir_unix"; ./config.status --file="-:-" <"$studiofile.in2" >"$studiofile.in" )

  # If we are making the Win32 precompiled SDK installer, we need to make
  # the .dsp-file contain relative paths that works from where the sources and
  # build files are going to be installed...
  # The first two rules are for individual source files, the next two are for
  # the include directive settings...

  sed -e "s%^SOURCE=.:.*\\(${Library}-[0-9]\\.[^/\\\\]*\\)%SOURCE=..\\\\source\\\\\\1%" \
      -e 's%^SOURCE=.:.*build-files%SOURCE=.%' \
      -e "s%.:[^ ]*\\(${Library}-[0-9]\\.[^/\\\\\"]*\\)%..\\\\source\\\\\\1%" \
      -e 's%.:[^ ]*build-files\([^"]*\)%.\1%g' \
      <"$studiofile.in" >"$studiofile.txt2"

  sourcedirregexp=`echo "$sourcedir" | sed -e 's%\\\\%\\\\\\\\%g'`
  builddirregexp=`echo "$builddir" | sed -e 's%\\\\%\\\\\\\\%g'`

  # Transform paths to be relative paths for non-installer-builds too.
  # This should probably be configurable in some way though.
  if test x"$sourcedir" = x"$builddir"; then
    relsourcedir="."
  else
    num=1
    while true; do
      presource=`echo $sourcedir | cut -d'\' -f1-$num`
      prebuild=`echo $builddir | cut -d'\' -f1-$num`
      if test x"$presource" = x"$prebuild"; then :; else
        break
      fi
      num=`expr $num + 1`
    done
    num=`expr $num - 1`
    if test $num -eq 0; then
      # relative path impossible
      relsourcedir=$sourcedirregexp
    else
      numplus=`expr $num + 1`
      # prefix=`echo $sourcedir | cut -d'\' -f1-$num`
      upfix=`echo "$builddir\\\\" | cut -d'\' -f$numplus- | sed -e 's%[^\\\\]*\\\\%..\\\\%g' -e 's%\\\\%\\\\\\\\%g'`
      postfix=`echo $sourcedir | cut -d'\' -f$numplus- | sed -e 's%\\\\%\\\\\\\\%g'`
      relsourcedir="$upfix$postfix"
    fi
  fi
  sed -e "s%$sourcedirregexp%$relsourcedir%g" \
      -e "s%$builddirregexp\\\\%.\\\\%g" \
      -e "s%$builddirregexp%.\\\\%g" \
    <"$studiofile.txt2" >"$studiofile.txt"

  # here we try to reverse some environment variable values back to their
  # variable references, to make the project less system-dependent.
  for var in $reversevars; do
    eval varval="\$$var"
    varval=`CYGWIN= cygpath -w "$varval" 2>/dev/null || echo "$varval"`
    varval="`echo $varval | sed -e 's%\\\\%\\\\\\\\%g'`"
    if test x"$varval" = x""; then :; else
      mv "$studiofile.txt" "$studiofile.txt2"
      sed -e "s%$varval%\\\$($var)%g" <"$studiofile.txt2" >"$studiofile.txt"
    fi
    if test -f "$studiofile.txt"; then :; else
      echo "error doing substitutions"
      echo "cmd: s%$varval%\\\$($var)%g"
      exit 1
    fi
  done

  # we want to link debug versions of this project with debug versions of the
  # libs they depend on.  we only do this for our own known libraries though.
  debuglibs="coin[0-9] soqt[0-9] sowin[0-9]"
  for lib in $debuglibs; do
    mv "$studiofile.txt" "$studiofile.txt2"
    sed -e '/\/debug/ s%\<\('$lib'\)\.lib\>%\1d.lib%g' <"$studiofile.txt2" >"$studiofile.txt"
    if test -f "$studiofile.txt"; then :; else
      echo "error doing substitutions"
      echo "cmd: s%$varval%\\\$($var)%g"
      exit 1
    fi
  done

  # do unix2dos conversion (\n -> \r\n) on the DevStudio files
  echo -e "s/\$/\r/;\np;" >unix2dos.sed
  sed -n -f unix2dos.sed "$studiofile.txt" >"$studiofile"
  sed -n -f unix2dos.sed "$workspacefile.txt" >"$workspacefile"
  # clean out temporary files
  rm -f "$studiofile.txt2" "$studiofile.txt" "$studiofile.in2" "$studiofile.in" "$workspacefile.txt" "$workspacefile.in" unix2dos.sed
  ;;
esac


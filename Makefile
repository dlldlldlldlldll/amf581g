# -----------------------------------------------#
#  Makefile for the AMF conversion code         #
#  Uses LIDORT code from R. Spurr               #
#
# Ordering oF modules follows that required for GNU - the linker
# needs the modules in a certain order (a called module must be
# already compiled and linked before).
# -----------------------------------------------#

SHELL = /bin/bash

# ------------------------------------------
# Compiler flags for the different HOSTTYPEs
# IFORT is default
# ------------------------------------------

#========
# dbm : prior to 4/4/6
# FC = ifort
# FFLAGS =  -fast -convert big_endian -openmp
# FPFLAG =  -fpp -fast -convert big_endian -openmp
#========

FC     = ifort
FFLAGS = -w -O2 -auto -noalign -convert big_endian -CB #-openmp
FPFLAG = -debug extended -fpp $(FFLAGS)


# ---------------------
# Linux EFC
# ---------------------
# tuque (dbm: this doesn't work for efc: it doesn't like 
#             the INCLUDE '../include_s/LIDORT.PARS' 
#             etc. statements in LIDORT_V23E_MASTER.f.
#             Changing them to 
#             INCLUDE 'include_s/LIDORT.PARS' etc.
#             seemed to work.
# FC = efc
# FFLAGS = -w -O2 -Vaxlib -tpp2
# FFLAGS = -cpp -w -O2 -Vaxlib -auto -noalign # from GEOS-Chem
# FPFLAG = $(FFLAGS) -cpp

# ---------------------
# SGI
# ---------------------
#FC = f90
#FFLAGS =  -64 -O3 -OPT:reorg_common=off -cpp
#FPFLAG =  $(FFLAGS)

# ---------------------

FF = $(FC) $(FFLAGS) -c
FP = $(FC) $(FPFLAG) -c

EXE = amf.run


# Path variables
################

# Define a variable LIDORT_PATH and users must change only this!

LIDORT_PATH = .

MPATH_S = $(LIDORT_PATH)/src_v23s_master/
MPATH_E = $(LIDORT_PATH)/src_v23e_master/
SPATH_S = $(LIDORT_PATH)/src_standard/
IPATH_S = $(LIDORT_PATH)/include_s/
SPATH_E = $(LIDORT_PATH)/src_extension/
IPATH_E = $(LIDORT_PATH)/include_e/

#  OBJECT MODULES
#################

# LIDORT modules in directory src_standard

OBJECTS_LIDORT_SOLUTIONS = LIDORT_RTSOLUTION.o LIDORT_MULTIPLIERS.o
OBJECTS_LIDORT_SETUPS    = LIDORT_MISCSETUPS.o LIDORT_DERIVEINPUT.o LIDORT_CHECKINPUT.o
OBJECTS_LIDORT_INTENSITY = LIDORT_BVPROBLEM.o  LIDORT_INTENSITY.o   LIDORT_CONVERGE.o LIDORT_SSCORRECTION.o
OBJECTS_LIDORT_AUX       = LIDORT_AUX.o        LIDORT_READINPUT.o   LIDORT_WRITEMODULES.o

# LIDORT modules in directory src_extension

OBJECTS_LIDORT_L_SOLUTIONS = LIDORT_L_RTSOLUTION.o LIDORT_L_MULTIPLIERS.o
OBJECTS_LIDORT_L_SETUPS    = LIDORT_L_MISCSETUPS.o LIDORT_L_CHECKINPUT.o
OBJECTS_LIDORT_L_WGHTFNS   = LIDORT_L_BVSETUPS.o   LIDORT_L_FOURIERADD.o LIDORT_L_WFCALC.o LIDORT_L_SSCORRECTION.o
OBJECTS_LIDORT_L_AUX       = LIDORT_L_INPUTREAD.o  LIDORT_L_WRITEMODULES.o

# LIDORT top level modules in directory src_v23e_master

OBJECTS_LIDORT_MASTERS   = LIDORT_V23E_MASTER.o LIDORT_V23E_INPUT.o LIDORT_V23E_FOURIER.o

OBJECTS_LIDORT_CROSSSEC  = cross_sections.combined.o

# environment & interface modules external to the main package

OBJECTS_LIDORT_ENVIRON  = amfgas_lidortenv.o \
                          amfgas_lidortprep.o


# For NaN/Inf error checks
OBJSe  =            \
linux_err.o

OBJS =             \
ioerror.o          \
CMN_SIZE_MOD.o     \
bpch2_mod.o        \
ParameterModule.o  \
makeatm.o          \
$(OBJECTS_LIDORT_ENVIRON)     \
$(OBJECTS_LIDORT_MASTERS)     \
$(OBJECTS_LIDORT_SETUPS)      \
$(OBJECTS_LIDORT_SOLUTIONS)   \
$(OBJECTS_LIDORT_INTENSITY)   \
$(OBJECTS_LIDORT_AUX)         \
$(OBJECTS_LIDORT_L_SETUPS)    \
$(OBJECTS_LIDORT_L_SOLUTIONS) \
$(OBJECTS_LIDORT_L_WGHTFNS)   \
$(OBJECTS_LIDORT_L_AUX)       \
$(OBJECTS_LIDORT_CROSSSEC) 


#The following require HDF libraries. Select HDF usage below at build executable
OBJS_hdf =         \
He5IncludeModule.o    \
He5ErrorModule.o      \
He5SwathModule.o      \
OmiModule.o           \
MAmfLut.o             \
Mrweight.o            \
Mlut_use.o

#satellite_IO needs HDF libraries only if OMI is defined in define.F
OBJS_sat = satellite_IO.o    #GOB Addition

# Library link commands (point to directory where libraries are installed)
#Lhe5   = -L/usr/lib64 -lhe5_hdfeos-hdf5 -lGctp-hdf5 -lhdf5 -lsz -lz -lm
Lhe5   = -L/usr/lib64 -Gctp-hdf5 -lhdf5 -lz -lm

#Additional HDF commands. Comment out if not needed
# Link to the HDF and HDF-EOS libraries in /usr/local/lib
#Fhdf    = -L/usr/lib64 -lmfhdf -ldf -lz -lm -ljpeg -lhdfeos -lGCtp
Fhdf    = -L/usr/lib64 -lz -lm -ljpeg -lhdfeos -lGctp

#==============================================================
#  Build executable   With HDF compatibility 
#                     Comment out if not using HDF files
#=============================================================
#amf     :  $(OBJS) $(OBJS_hdf) $(OBJSe) $(OBJS_sat) Makefile
#	$(FC) $(FFLAGS) main.F $(OBJS) $(OBJS_hdf) $(OBJSe) $(OBJS_sat) $(Lhe5) $(Fhdf) -o $(EXE)

#==============================================================
#  Build executable   Without HDF compatibility
#                     Comment out if using HDF files
#=============================================================
amf     :  $(OBJS) $(OBJSe) $(OBJS_sat) Makefile
	$(FC) $(FFLAGS) main.F $(OBJS) $(OBJSe) $(OBJS_sat) -o $(EXE)



#=============================================================
#  Dependencies Listing
#==============================================================

ioerror.o            : ioerror.F 
bpch2_mod.o          : bpch2_mod.F CMN_SIZE_MOD.f90
ParameterModule.o    : ParameterModule.f90
CMN_SIZE_MOD.o       : CMN_SIZE_MOD.f90   define.h      # GOB addition

# dbm modification for HDF5
He5IncludeModule.o     : He5IncludeModule.f90 define.h 
He5ErrorModule.o       : He5ErrorModule.f90 define.h
He5SwathModule.o       : He5SwathModule.f90 
OmiModule.o            : OmiModule.f90 define.h ParameterModule.f90
Mlut_use.o	       : Mlut_use.F        CMN_SIZE_MOD.f90 define.h     # GOB addition
linux_err.o            : linux_err.c
	gcc -c linux_err.c

main.o               : main.F \
	 CMN_SIZE_MOD.f90         \
	 define.h         \
         ParameterModule.f90 \
	 $(IPATH_S)LIDORT.PARS         \
	 $(IPATH_E)LIDORT_L.PARS       \
	 $(IPATH_S)LIDORT_CONTROL.VARS \
	 $(IPATH_E)LIDORT_L_CONTROL.VARS \
	 $(IPATH_S)LIDORT_MODEL.VARS   \
	 $(IPATH_S)LIDORT_GEOPHYS.VARS
#	$(FF) main.F

makeatm.o            : makeatm.F           CMN_SIZE_MOD.f90 define.h
satellite_IO.o       : satellite_IO.f90 define.h ParameterModule.f90 # GOB addition

amfgas_lidortenv.o: amfgas_lidortenv.F \
	 CMN_SIZE_MOD.f90         \
	 define.h         \
	 $(IPATH_S)LIDORT.PARS         \
	 $(IPATH_E)LIDORT_L.PARS       \
	 $(IPATH_S)LIDORT_CONTROL.VARS \
	 $(IPATH_E)LIDORT_L_CONTROL.VARS \
	 $(IPATH_S)LIDORT_SETUPS.VARS \
	 $(IPATH_S)LIDORT_MODEL.VARS   \
	 $(IPATH_S)LIDORT_GEOPHYS.VARS   \
	 $(IPATH_S)LIDORT_RESULTS.VARS
#	$(FF) amfgas_lidortenv.F

amfgas_lidortprep.o: amfgas_lidortprep.F \
	 $(IPATH_S)LIDORT.PARS           \
	 $(IPATH_E)LIDORT_L.PARS         \
	 $(IPATH_S)LIDORT_CONTROL.VARS   \
	 $(IPATH_S)LIDORT_GEOPHYS.VARS   \
	 $(IPATH_S)LIDORT_MODEL.VARS     \
	 $(IPATH_E)LIDORT_L_GEOPHYS.VARS
#	$(FF) amfgas_lidortprep.F



#------------------------------------------- library module

cross_sections.combined.o: cross_sections.combined.f
#	$(FF) cross_sections.combined.f


include lidort.make


#=============================================================================
#  Other Makefile Commands
#=============================================================================
clean:
	rm -f *.o *.mod *.il $(EXE)

.SUFFIXES: .f .F .f90 .F90
#.f.o:			; $(FF) $*.f
#.F.o:			; $(FF) $*.F
#.f90.o:                 ; $(FF) $*.f90 
#.F90.o:                 ; $(FF) $*.F90 

# ===============================================================
# "Pattern rules: How to make a *.o file from a *.f or a *.F file
# ===============================================================
.f.o:
	$(FF) $< 
.F.o:
	$(FF) $<

.f90.o:
#	$(FF) -cpp -w -O2 -auto -noalign -free $< -o $@
	$(FF) -cpp -w -O2 -auto -noalign -free $*.f90 

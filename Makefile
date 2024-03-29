# Enables debug mode
DEBUG := 0
# Override default compiler and flags
OVERRIDE_DEFAULT_CXX := 1
# Measure performance in tests
MEASURE_PERFORMANCE := 0

LIBNAME := libabr

TARGETS_ONLYTEST := \
    abr_gadget \
    fixed_abr \
    fixed_mtree \
    mimc256 \
    mimc256_gadget \
    mimc512f \
    mimc512f_gadget \
	mimc512f2k \
	mimc512f2k_gadget \
    mtree_gadget \
    sha256 \
    sha512

TARGETS_TEST :=
TARGETS_NOTEST := \
    benchmark_mtree \
    benchmark_abr
    

ifeq ($(CXX), )
    CXX := c++
    CXXFLAGS := -O3 -march=native -std=c++17 -Wall
endif

ifeq ($(OVERRIDE_DEFAULT_CXX), 1)
    CXX := c++
    CXXFLAGS := -O3 -march=native -std=c++17
endif

ifeq ($(DEBUG), 1)
    CXXFLAGS = -std=c++17 -g -Wall
endif

TESTPATH := test
SRCPATH := src
SRC := $(wildcard $(SRCPATH)/*.cpp $(SRCPATH)/**/*.cpp)

INCPATH := include
INC := $(wildcard $(INCPATH)/*.h $(INCPATH)/**/*.h $(INCPATH)/*.hpp $(INCPATH)/**/*.hpp)

BUILDPATH := build
BINPATH := bin
LIBPATH := lib

LDFLAGS := -lff -lgmp -lgmpxx -lsnark -lprocps
AR := ar
ARFLAGS := r
CXXFLAGS += -fopenmp
OEXT := o
LIBEXT := a
PDB :=
TARGETS_$(TEST_PRE)COMMAND := $(TARGETS_TEST:%=$$SCRIPTPATH/%;\n)$(TARGETS_ONLYTEST:%=$$SCRIPTPATH/%;\n)
MKDIR = mkdir -p $(1)
RM = rm -rf $(1)/*
MV = mv $(1) $(2)/
CP = cp $(1) $(2)/

ifeq ($(MEASURE_PERFORMANCE), 1)
    CXXFLAGS += -DMEASURE_PERFORMANCE
endif

CXXFLAGS += -I$(INCPATH)
CXX20FLAGS := $(CXXFLAGS) -std=c++20

SRCNAMES := $(notdir $(SRC))
OBJ := $(SRCNAMES:%.cpp=$(BUILDPATH)/%.$(OEXT))

TARGETS := $(TARGETS_ONLYTEST) $(TARGETS_TEST) $(TARGETS_NOTEST)

LIBSNAMES := $(TARGETS_TEST) $(TARGETS_NOTEST)

LIBS := $(LIBSNAMES:%=$(BUILDPATH)/%.$(OEXT))

DEP := $(OBJ:%.$(OEXT)=%.d) 

TEST_PRE = test_

all: dirs testsuite $(TARGETS) library
    

clean:
	$(call RM,$(BUILDPATH))
	$(call RM,$(BINPATH))
	$(call RM,$(LIBPATH))


dirs:
	$(call MKDIR,$(BUILDPATH))
	$(call MKDIR,$(BINPATH))
	$(call MKDIR,$(LIBPATH))

testsuite:
	@echo -e '#!/bin/sh\nSCRIPTPATH=$$(dirname "$$(readlink -f "$$0")")\n$(TARGETS_$(TEST_PRE)COMMAND)' > $(BINPATH)/test.sh

library: $(TARGETS)
	$(AR) $(ARFLAGS) $(LIBOUTFLAGS)$(LIBPATH)/$(LIBNAME).$(LIBEXT) $(LIBS)


###################### BEGIN RULES ######################

#### TARGET_ONLYTEST ####
abr_gadget:  %: $(BUILDPATH)/$(TEST_PRE)%.$(OEXT)
	$(CXX) $(CXXFLAGS) $^ -o $(BINPATH)/$@ $(LDFLAGS)

fixed_abr:  %: $(BUILDPATH)/$(TEST_PRE)%.$(OEXT)
	$(CXX) $(CXXFLAGS) $^ -o $(BINPATH)/$@ $(LDFLAGS)

fixed_mtree:  %: $(BUILDPATH)/$(TEST_PRE)%.$(OEXT)
	$(CXX) $(CXXFLAGS) $^ -o $(BINPATH)/$@ $(LDFLAGS)

mimc256:  %: $(BUILDPATH)/$(TEST_PRE)%.$(OEXT)
	$(CXX) $(CXXFLAGS) $^ -o $(BINPATH)/$@ $(LDFLAGS)

mimc256_gadget:  %: $(BUILDPATH)/$(TEST_PRE)%.$(OEXT)
	$(CXX) $(CXXFLAGS) $^ -o $(BINPATH)/$@ $(LDFLAGS)

mimc512f:  %: $(BUILDPATH)/$(TEST_PRE)%.$(OEXT)
	$(CXX) $(CXXFLAGS) $^ -o $(BINPATH)/$@ $(LDFLAGS)

mimc512f_gadget:  %: $(BUILDPATH)/$(TEST_PRE)%.$(OEXT)
	$(CXX) $(CXXFLAGS) $^ -o $(BINPATH)/$@ $(LDFLAGS)

mimc512f2k:  %: $(BUILDPATH)/$(TEST_PRE)%.$(OEXT)
	$(CXX) $(CXXFLAGS) $^ -o $(BINPATH)/$@ $(LDFLAGS)

mimc512f2k_gadget:  %: $(BUILDPATH)/$(TEST_PRE)%.$(OEXT)
	$(CXX) $(CXXFLAGS) $^ -o $(BINPATH)/$@ $(LDFLAGS)

mtree_gadget:  %: $(BUILDPATH)/$(TEST_PRE)%.$(OEXT)
	$(CXX) $(CXXFLAGS) $^ -o $(BINPATH)/$@ $(LDFLAGS)

sha256:  %: $(BUILDPATH)/$(TEST_PRE)%.$(OEXT)
	$(CXX) $(CXXFLAGS) $^ -o $(BINPATH)/$@ $(LDFLAGS)

sha512:  %: $(BUILDPATH)/$(TEST_PRE)%.$(OEXT)
	$(CXX) $(CXXFLAGS) $^ -o $(BINPATH)/$@ $(LDFLAGS)


#### TARGET_NOTEST ####
benchmark_mtree:  %: $(BUILDPATH)/%.$(OEXT)
	$(CXX) $(CXXFLAGS) $^ -o $(BINPATH)/$@ $(LDFLAGS)

benchmark_abr:  %: $(BUILDPATH)/%.$(OEXT)
	$(CXX) $(CXXFLAGS) $^ -o $(BINPATH)/$@ $(LDFLAGS)

###################### END RULES ######################

-include $(DEP)

$(BUILDPATH)/$(TEST_PRE)%.$(OEXT): $(TESTPATH)/%.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILDPATH)/$(TEST_PRE)%.$(OEXT): $(TESTPATH)/cpp20/%.cpp
	$(CXX) $(CXX20FLAGS) -c $< -o $@

$(BUILDPATH)/%.$(OEXT): $(SRCPATH)/%.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILDPATH)/%.$(OEXT): $(SRCPATH)/**/%.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

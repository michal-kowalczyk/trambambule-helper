# always force this build to re-run its dependencies
FORCE_GYP := $(shell make --debug -C ../../../ GypAndroid.mk)
include ../../../GypAndroid.mk

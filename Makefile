OUT_DIR=tmp
CMD_PREFIX=bundle exec
VERSION=$(shell semver)
TODAY=$(shell date +%F)

# You want latexmk to *always* run, because make does not have all the info.
# Also, include non-file targets in .PHONY so they are run regardless of any
# file of the given name existing.
.PHONY: all test clean setup ruby packages preprocess

# The first rule in a Makefile is the one executed by default ("make"). It
# should always be the "all" rule, so that "make" and "make all" are identical.
all: test

# CUSTOM BUILD RULES
test:
	$(CMD_PREFIX) ruby -I test test/**/*_test.rb

clean:
	# noop

##
# Set up the project for building
setup: ruby packages

ruby:
	bundle install

packages:
	sudo apt install ruby

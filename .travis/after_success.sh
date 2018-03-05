#!/bin/bash

source .travis/common.sh
set -e

# Close the after_success fold travis has created already.
travis_fold end after_success

start_section "package.contents" "${GREEN}Package contents...${NC}"
tar -jtf $CONDA_OUT | sort
end_section "package.contents"


if [ x$TRAVIS_BRANCH = x"master" -a x$TRAVIS_EVENT_TYPE != x"cron" ]; then
	$SPACER

	start_section "package.upload" "${GREEN}Package uploading...${NC}"
	anaconda -t $ANACONDA_TOKEN upload --user $ANACONDA_USER $CONDA_OUT
	end_section "package.upload"
fi

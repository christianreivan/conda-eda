#!/bin/bash

# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -ex

mkdir -p $PREFIX/share/pdk
curl --silent -L https://github.com/efabless/volare/releases/download/gf180mcu-$OPEN_PDKS_REV/default.tar.xz | tar -xvJf - -C $PREFIX/share/pdk gf180mcuC/

# fix xschem tests
curl --silent -L https://github.com/efabless/globalfoundries-pdk-libs-gf180mcu_fd_pr/pull/24.patch | patch -d $PREFIX/share/pdk/gf180mcuC/libs.tech/xschem -p3
curl --silent -L https://github.com/efabless/globalfoundries-pdk-libs-gf180mcu_fd_pr/pull/29.patch | patch -d $PREFIX/share/pdk/gf180mcuC/libs.tech/xschem -p3

# patch improved xschem LVS export
curl --silent -L https://github.com/efabless/globalfoundries-pdk-libs-gf180mcu_fd_pr/pull/23.patch | patch -d $PREFIX/share/pdk/gf180mcuC/libs.tech/xschem -p3

# fix drc rules
curl --silent -L https://github.com/efabless/globalfoundries-pdk-libs-gf180mcu_fd_pr/pull/25.patch | patch -d $PREFIX/share/pdk/gf180mcuC/libs.tech/klayout -p3

# discover xschem LVS netlist
curl --silent -L https://github.com/efabless/globalfoundries-pdk-libs-gf180mcu_fd_pr/pull/26.patch | patch -d $PREFIX/share/pdk/gf180mcuC/libs.tech/klayout -p3

# add missing macros for klayout menus
curl --silent -L https://github.com/efabless/globalfoundries-pdk-libs-gf180mcu_fd_pr/archive/refs/heads/main.tar.gz | tar xvzf - --strip-components=3 -C $PREFIX/share/pdk/gf180mcuC/libs.tech/klayout/ globalfoundries-pdk-libs-gf180mcu_fd_pr-main/rules/klayout/macros

# revert to non-gdsfactory pcells
rm -r $CONDA_PREFIX/share/pdk/gf180mcuC/libs.tech/klayout/pymacros/
curl --silent -L https://github.com/efabless/globalfoundries-pdk-libs-gf180mcu_fd_pr/tarball/2f6d54028df54279a92960a545680baf09a1154a | tar xvzf - --strip-components=3 -C $PREFIX/share/pdk/gf180mcuC/libs.tech/klayout/ efabless-globalfoundries-pdk-libs-gf180mcu_fd_pr-2f6d540/cells/klayout/ --exclude='*testing*'

# link klayout drc/lvs/pymacros path with symlink for interactive usage
# keep existing file in place because openlane need them
# https://www.klayout.de/doc/about/technology_manager.html#:~:text=The%20technology%20folder%20may%20have%20subfolders%20to%20hold%20library%20files%2C%20macros%2C%20DRC%20runsets%2C%20LEF%20files%20and%20other%20pieces%20of%20the%20technology%20package.
# https://github.com/RTimothyEdwards/open_pdks/issues/346
ln -s ../drc $PREFIX/share/pdk/gf180mcuC/libs.tech/klayout/tech/drc
ln -s ../lvs $PREFIX/share/pdk/gf180mcuC/libs.tech/klayout/tech/lvs
mkdir $PREFIX/share/pdk/gf180mcuC/libs.tech/klayout/tech/pymacros
ln -s ../../pymacros $PREFIX/share/pdk/gf180mcuC/libs.tech/klayout/tech/pymacros/cells
ln -s ../gf180mcu.lym $PREFIX/share/pdk/gf180mcuC/libs.tech/klayout/tech/pymacros/gf180mcu.lym

# merge drc files for interactive usage
DRC_MERGE_DIR=$(mktemp -d)
cp $PREFIX/share/pdk/gf180mcuC/libs.tech/klayout/drc/rule_decks/*.drc $DRC_MERGE_DIR/
rm $DRC_MERGE_DIR/{main,tail}.drc
cat $PREFIX/share/pdk/gf180mcuC/libs.tech/klayout/drc/rule_decks/main.drc > $PREFIX/share/pdk/gf180mcuC/libs.tech/klayout/drc/gf180mcu.drc
cat $DRC_MERGE_DIR/*.drc >> $PREFIX/share/pdk/gf180mcuC/libs.tech/klayout/drc/gf180mcu.drc
cat $PREFIX/share/pdk/gf180mcuC/libs.tech/klayout/drc/rule_decks/tail.drc >> $PREFIX/share/pdk/gf180mcuC/libs.tech/klayout/drc/gf180mcu.drc

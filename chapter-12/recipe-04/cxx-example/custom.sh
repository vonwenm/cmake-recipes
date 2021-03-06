#!/usr/bin/env bash

# build directory is provided by the main script
build_directory=$1
mkdir -p ${build_directory}
cd ${build_directory}

PATH=$HOME/Deps/conda/bin${PATH:+:$PATH}

conda create -q --name test-environment-dgemm
source activate test-environment-dgemm

cp -r ../conda-recipe .
cp ../CMakeLists.txt .
cp ../example.cpp .

conda build conda-recipe
conda install --use-local conda-example-dgemm

dgemm-example

exit $?

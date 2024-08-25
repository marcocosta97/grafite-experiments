#/bin/bash

#
# This file is part of Grafite <https://github.com/marcocosta97/grafite>.
# Copyright (C) 2023 Marco Costa.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

LATEX_LINK="https://data.d4science.net/vRaZ"
LATEX_FILE="latex.zip"

WORKDIR="/app/"
GRAFITE_FOLDER="${WORKDIR}grafite/"
PAPER_RESULTS_FOLDER="${WORKDIR}paper_results/"
HOST_OUTPUT_FOLDER="${WORKDIR}paper_results/"

# download a zip passed as argument using wget and extract it
# $1: link to the zip file
# $2: name of the zip file
download_and_extract() {
    # Retry wget every 10 seconds if it fails
    while true; do
        wget --content-disposition $1 && break || { echo "[ERROR] Failed to download the file $2"; sleep 10; }
        echo "[ERROR] Retrying in 10 seconds..."
        sleep 10
    done
    unzip $2 -d "${2%.zip}" || { echo "[ERROR] Failed to extract the file $2"; exit 1; } && rm $2 || { echo "[ERROR] Failed to extract the file $2"; exit 1; }
}

set -e
echo "[INFO] Reproducing the experiments from the paper \"Grafite: Taming Adversarial Queries with Optimal Range Filters\""
echo "[INFO] This script will install the dependencies, download the datasets, run the experiments, generate the plots and LaTeX paper."
sleep 5

#######################################
# Install dependencies and compile Grafite
#######################################
echo "[INFO] Installing dependencies"
pip3 install jupyter matplotlib numpy pandas || { echo "[ERROR] Failed to install dependencies"; exit 1; }
echo "[INFO] Dependencies installed"
# Download and compile Grafite
echo "[INFO] Downloading and compiling Grafite"
sleep 2
git clone --recurse-submodules -j8 https://github.com/marcocosta97/grafite.git || { echo "[ERROR] Failed to download Grafite"; exit 1; }
cd grafite
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release || { echo "[ERROR] Failed to configure Grafite"; exit 1; }
make -j8 || { echo "[ERROR] Failed to compile Grafite"; exit 1; }
echo "[INFO] Grafite and benchmarks compiled"

#######################################
# Download and generate the datasets
#######################################
echo "[INFO] Downloading and generating the datasets"
cd ${WORKDIR}
bash ${GRAFITE_FOLDER}bench/scripts/download_datasets.sh || { echo "[ERROR] Failed to download datasets"; exit 1; }
bash ${GRAFITE_FOLDER}bench/scripts/generate_datasets.sh ${GRAFITE_FOLDER}build real_datasets || { echo "[ERROR] Failed to generate datasets"; exit 1; }
rm -rf ${WORKDIR}real_datasets || { echo "[ERROR] Failed to remove real_datasets folder"; exit 1; }
# To save computation time we remove datasets that are not used in the paper.
# However, we still need to generate them to guarantee the reproducibility of
# the other datasets, since the workload generation uses an incremental seed.
find ${WORKDIR}workloads -type d -name "10M*" -prune -exec rm -rf {} \; || { echo "[ERROR] Failed to remove 10M datasets"; exit 1; }
find ${WORKDIR}workloads -type d -name fb -prune -exec rm -rf {} \; || { echo "[ERROR] Failed to remove fb dataset"; exit 1; }
echo "[INFO] Datasets generated"

#######################################
# Run the experiments
#######################################
echo "[INFO] Running the experiments, this will take approximately a couple of days. Enjoy the flight!"
mkdir -p ${PAPER_RESULTS_FOLDER} && cd ${PAPER_RESULTS_FOLDER} || { echo "[ERROR] Failed to create paper_results directory"; exit 1; }
bash ${GRAFITE_FOLDER}bench/scripts/execute_tests.sh ${GRAFITE_FOLDER}build ${WORKDIR}workloads || { echo "[ERROR] Failed to execute the experiments"; exit 1; }
echo "[INFO] Experiments executed"
# Find all empty result files of executions that have not been 
# executed correctly, and print them in paper_results/log.txt
find ${PAPER_RESULTS_FOLDER}results -type f -empty -exec echo "Not executed correctly: {}" \; > ${PAPER_RESULTS_FOLDER}log.txt

#######################################
# Generate the plots
#######################################
echo "[INFO] Generating the plots"
cp ${GRAFITE_FOLDER}bench/scripts/graphs.ipynb . || { echo "[ERROR] Failed to copy graphs notebook"; exit 1; }
jupyter execute graphs.ipynb || { echo "[ERROR] Failed to execute graphs notebook"; exit 1; }

#######################################
# Generate the pdf of the paper
#######################################
echo "[INFO] Downloading the LaTeX paper source code"
cd ${WORKDIR}
download_and_extract $LATEX_LINK $LATEX_FILE || { echo "[ERROR] Failed to download the LaTeX paper"; exit 1; }
cd latex
cp -a ${PAPER_RESULTS_FOLDER}figures/. figures_pacmmod/ || { echo "[ERROR] Failed to copy experiment results"; exit 1; }
echo "[INFO] Generating the LaTeX paper"
latexmk -bibtex -pdf main || { echo "[ERROR] Failed to generate LaTeX paper"; exit 1; }

#######################################
# Copy the results to the output 
# directory on the host machine
#######################################
echo "[INFO] Copying the results to the output directory"
mkdir -p ${HOST_OUTPUT_FOLDER} || { echo "[ERROR] Failed to create output directory"; exit 1; }
cp ${WORKDIR}latex/main.pdf ${HOST_OUTPUT_FOLDER} || { echo "[ERROR] Failed to copy LaTeX paper"; exit 1; }
if [ ${PAPER_RESULTS_FOLDER} != ${HOST_OUTPUT_FOLDER} ]; then
    cp -r ${PAPER_RESULTS_FOLDER}results ${HOST_OUTPUT_FOLDER} || { echo "[ERROR] Failed to copy experiment results"; exit 1; }
    cp -r ${PAPER_RESULTS_FOLDER}figures ${HOST_OUTPUT_FOLDER} || { echo "[ERROR] Failed to copy experiment figures"; exit 1; }
fi
echo "[INFO] All done! The results are in the output directory. Thanks for using Grafite!"

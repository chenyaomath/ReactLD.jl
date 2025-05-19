#!/bin/bash

# Function to run a Julia script in background
run_julia() {
    local num_sim=$1
    local time_step=$2
    local date=$3

    nohup julia AB_C_X.jl \
        --num_sim $num_sim \
        --time_step $time_step \
        > logs/ABCX_sim${num_sim}_time_step${time_step}_$date.log \
        2>&1 &
}

export JULIA_NUM_THREADS=14

# Run Julia scripts in parallel
# run_julia 40000 1.0e-6 24072110 
# run_julia 40000 1.0e-6 24072110
# run_julia 40000 1.0e-6 24072110
# run_julia 40000 1.0e-6 24072110
# run_julia 40000 1.0e-6 24072110
# run_julia 40000 1.0e-6 24072110

# test
cur_time=$(date +"%y%m%d%H")
run_julia 500 1.0e-6 $cur_time

echo "AB_C_X scripts started!"
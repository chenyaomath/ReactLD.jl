#!/bin/bash

# Function to run a Julia script in background
run_julia() {
    local num_sim=$1
    local beta=$2
    local time_step=$3
    local date=$4

    #nohup JULIA_NUM_THREADS=$num_threads julia ReactLD.jl --num_sim $num_sim --beta $beta --time_step $time_step 
    #> logs/ABCV_sim${num_sim}_beta${beta}_time_step${time_step}_${date}.log 2>&1 &
    nohup julia ReactLD.jl  \
        --num_sim $num_sim \
        --beta $beta \
        --time_step $time_step \
        > logs/ABCV_sim${num_sim}_beta${beta}_time_step${time_step}_$date.log \
        2>&1 &
}

export JULIA_NUM_THREADS=14

# Run Julia scripts in parallel
cur_time=$(date +"%y%m%d%H")
# run_julia 500 1.0e3 1.0e-6 $cur_time
# run_julia 500 1.0e4 1.0e-6 $cur_time
# run_julia 500 1.0e5 1.0e-6 $cur_time
# run_julia 500 1.0e6 1.0e-6 $cur_time

run_julia 500 1.0e2 1.0e-6 $cur_time
# run_julia 500 1.0e8 1.0e-6 $cur_time

echo "experiments script started!"
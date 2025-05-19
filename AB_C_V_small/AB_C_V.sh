#!/bin/bash

# Function to run a Julia script in background
run_julia() {
    local num_sim=$1
    local time_step=$2
    local beta=$3
    local date=$4
    nohup julia AB_C_V.jl --num_sim $num_sim --beta $beta --time_step $time_step > logs/ABCV_sim${num_sim}_beta${beta}_time_step${time_step}_$date.log 2>&1 &
}

# Run Julia scripts in parallel
# run_julia 20000 1.0    1.0e-7 24071509
# run_julia 20000 1.0e-1 1.0e-7 24071509
# run_julia 20000 1.0e-2 1.0e-7 24071509
# run_julia 20000 1.0e-3 1.0e-7 24071509
# run_julia 20000 1.0e-4 1.0e-7 24071509
# run_julia 20000 1.0e-5 1.0e-7 24071509


run_julia 40000 1.0e-7 1.0    24071610 
run_julia 40000 1.0e-7 1.0e-1 24071610
run_julia 40000 1.0e-7 1.0e-2 24071610
run_julia 40000 1.0e-7 1.0e-3 24071610
run_julia 40000 1.0e-7 1.0e-4 24071610
run_julia 40000 1.0e-7 1.0e-5 24071610

echo "AB_C_V scripts started!"
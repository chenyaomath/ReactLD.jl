#!/bin/bash

# Function to run a Julia script in background
run_julia() {
    local test=$1
    local num=$2
    nohup julia test.jl --num $num > test${test}.log 2>&1 &
}

# Run Julia scripts in parallel
run_julia 0 30
run_julia 1 31
run_julia 2 32

echo "Julia scripts started!"



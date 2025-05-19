using Pkg
Pkg.activate(".")

Pkg.add("ProgressMeter")
using ProgressMeter

@showprogress for i in 1:15
    sleep(10)
end

# julia test.jl > test.log 2>&1 &
# tail -n 20 -f test.log

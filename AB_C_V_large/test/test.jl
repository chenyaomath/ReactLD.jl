using Pkg
Pkg.activate(".")

Pkg.add("ArgParse")
Pkg.add("ProgressMeter")

using ArgParse, ProgressMeter

function main(args)

    s = ArgParseSettings()

    @add_arg_table s begin
        "--num"
        arg_type = Int64
        default  = 30
    end

    parsed_args = parse_args(args, s)

    # Parameters from command inputs
    N = parsed_args["num"]

    @showprogress for i in 1:N
        # println("$i")
        sleep(10)
    end
end

# Call the main function if this script is run directly
if abspath(PROGRAM_FILE) == @__FILE__
    main(ARGS)
end

# command line:
# ps aux | grep julia
# nohup julia test.jl --num 30 > test_num30.log 2>&1 &
# tail -n 50 -f test_num30.log
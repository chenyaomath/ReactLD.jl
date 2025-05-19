const DIM = 3  # dim of the domain

mutable struct Particle
    X::SVector{DIM,Float64}
end

mutable struct ReactState
    dir::Float64
    A::Particle
    B::Particle
    C::Particle
end


"""
    period_dist(X1, X2, p) -> Float64

Description: 
    Calculate the periodic distance between two positions.
"""
function period_dist(X1, X2, p)
    (; Ω_sup) = p
    diff1 = abs.(X1 - X2)
    diff2 = Ω_sup .- diff1
    return norm(min.(diff1, diff2))
end

"""
    update_state(ReactState, p::NamedTuple) -> NULL

Description: 
    Update one state (AB or C) considering both diffusion and reaction.
"""
function update_state(state, p)
    (; λ₁Δt, λ₀Δt, ε, Ω_sup) = p

    # Forward reaction-diffusion 
    if state.dir == 1.0
        # forward diffusion
        X1, X2 = forward_diff(state.A.X, state.B.X, p)

        if (rand() <= λ₁Δt) && (period_dist(X1, X2, p) <= ε)
            # forward reaction
            X3 = 0.5 * (X1 + X2)
            state.C.X = mod.(X3, Ω_sup)
            state.dir = 0.0
        else
            state.A.X = X1
            state.B.X = X2
        end
        
    # Backward reaction-diffusion
    else
        # backward diffusion
        X3 = backward_diff(state.C.X, p)

        if (rand() <= λ₀Δt)
            # backward reaction
            X1, X2 = backward_react(X3, p)
            state.A.X = X1
            state.B.X = X2
            state.dir = 1.0
        else
            state.C.X = X3
        end
    end
end

"""
    init_states(Int, p::NamedTuple) -> Vector{ReactState}

Description: 
    Initilize the vector of ReactStates with num_states length.
"""
function init_states(num_states, p)
    (; Ω_sup) = p
    
    react_states = Vector{ReactState}(undef, num_states)
    for i in 1:num_states
        init_dir = 0.0

        init_X1 = Ω_sup * (@SVector rand(3))
        init_A = Particle(init_X1)

        init_X2 = Ω_sup * (@SVector rand(3))
        init_B = Particle(init_X2)
        
        init_X3 = Ω_sup * (@SVector rand(3))
        init_C = Particle(init_X3)

        init_state = ReactState(init_dir, init_A, init_B, init_C)
        react_states[i] = init_state
    end
    return react_states
end

"""
    count_C(Vector{ReactState}, Int) -> Int

Description: 
    Count the number of C particles at iΔt step in the n-th simulation.
"""
function count_C(react_states, num_states)
    num_AB = 0.0
    for i in 1:num_states
        num_AB += react_states[i].dir
    end
    return (num_states - num_AB)
end


"""
    save_result(Vector, Vector, Int64) -> NULL
"""
function save_result(means, num_sim, p)
    (; Ω_sup, Δt, T) = p
    # Store
    df = DataFrame(mean=means)
    file_path = "results/ABCX_per_sim$num_sim" * "_Ω$Ω_sup" * "_Δt$Δt" * "_T$T.csv"
    CSV.write(file_path, df)
end
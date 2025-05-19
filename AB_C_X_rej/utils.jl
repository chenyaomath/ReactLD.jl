const DIM = 3  # dim of the domain

mutable struct Particle
    X::SVector{DIM,Float64}
end

mutable struct ReactState
    dir::Bool
    A::Particle
    B::Particle
    C::Particle
end


"""
    init_states(Int, p::NamedTuple) -> Vector{ReactState}

Description: 
    Initilize the vector of ReactStates with num_states length.
"""
function init_states(num_states, p)
    (; Ω_sup) = p
    react_states = []
    for _ in 1:num_states
        init_dir = 0

        # Initialize positions
        init_X1 = Ω_sup * (@SVector rand(3))
        init_X2 = Ω_sup * (@SVector rand(3))
        init_X3 = Ω_sup * (@SVector rand(3))

        # Initialize particles
        init_A = Particle(init_X1)
        init_B = Particle(init_X2)
        init_C = Particle(init_X3)

        init_state = ReactState(init_dir, init_A, init_B, init_C)
        push!(react_states, init_state)
    end
    return react_states
end


"""
    update_state(ReactState, p::NamedTuple) -> NULL

Description: 
    Update one state (AB or C) considering both diffusion and reaction.
"""
function update_state(state, p)
    (; λ, Δt, ε, β) = p

    # Forward reaction-diffusion 
    if state.dir
        # forward diffusion
        X1, X2 = forward_diff(state.A.X, state.B.X, p)

        ξ = rand()
        if (ξ <= λ * Δt) && (norm(X1 - X2) <= ε)
            # forward reaction
            X3 = 0.5 * (X1 + X2)

            state.C.X = X3
            state.dir = 0
        else
            state.A.X = X1
            state.B.X = X2
        end

    # Backward reaction-diffusion
    else
        # backward diffusion
        X3 = backward_diff(state.C.X, p)

        ξ = rand()
        if (ξ <= β * Δt)
            # backward reaction
            product_outside, X1, X2 = backward_react(X3, p)
            if product_outside
                state.C.X = X3
            else
                state.A.X = X1
                state.B.X = X2
                state.dir = 1
            end
        else
            state.C.X = X3
        end
    end
end


"""
    reflect(Vector{ReactState}, Int) -> Int

Description: 
    Count the number of C particles at iΔt step in the n-th simulation.
"""
function count_C(react_states, num_states)
    num_C = 0
    for i in 1:num_states
        num_C += (1 - react_states[i].dir)
    end
    return num_C
end


"""
    reflect(X::SVector{DIM,Float64}, p::NamedTuple) -> (Bool, SVector)

Description: 
    Reflect the coordinates of outside point X into the region Ω.
"""
function reflect(X, p)
    # initialize
    (; Ω_inf, Ω_sup) = p
    reflected_X = X
    drift_not_far = true

    for i in 1:DIM
        # if outside Ω
        if (Ω_inf <= X[i] <= Ω_sup) == 0
            # if drift too far
            if (X[i] < -Ω_sup) || (X[i] > 2 * Ω_sup)
                drift_not_far = false
                return (drift_not_far, X)
                # if out of Ω, but drift not far
            else
                # reflect
                @set! reflected_X[i] = Ω_sup - mod(X[i], Ω_sup)
                # test: 20 - mod(32, 20), 20 - mod(-8, 20)
            end
        end
    end
    return (drift_not_far, reflected_X)
end


"""
    save_result(Vector, Vector, Int64) -> NULL
"""
function save_result(means, stds, num_sim)
    # Store
    df = DataFrame(mean=means, std=stds)
    file_path = "result_sim$num_sim.csv"
    CSV.write(file_path, df)
end


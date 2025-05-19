function forward_diff(X1, V1, X2, V2, p)
    # unpack variables from p 
    (; Ω_sup, Δt, β₁δ₁, β₂δ₂, β₁Δt_plus_1, β₂Δt_plus_1) = p

    Z1 = @SVector randn(3)
    V1_next = (V1 + β₁δ₁ * Z1) / β₁Δt_plus_1
    X1_next = X1 + V1_next * Δt
    X1_next = mod.(X1_next, Ω_sup)

    Z2 = @SVector randn(3)
    V2_next = (V2 + β₂δ₂ * Z2) / β₂Δt_plus_1
    X2_next = X2 + V2_next * Δt
    X2_next = mod.(X2_next, Ω_sup)

    return (X1_next, V1_next,
            X2_next, V2_next)
end

function backward_diff(X3, V3, p)
    (; Ω_sup, Δt, β₃δ₃, β₃Δt_plus_1) = p

    # implicit method
    Z = @SVector randn(3)
    V3_next = (V3 + β₃δ₃ * Z) / β₃Δt_plus_1
    X3_next = X3 + V3_next * Δt
    X3_next = mod.(X3_next, Ω_sup)

    return (X3_next, V3_next)
end
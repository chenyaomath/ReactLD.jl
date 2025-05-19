function forward_react(X1, V1, X2, V2, p)
    (; γ₁, Ω_sup, m1_over_m3, m2_over_m3) = p
    # X3 = γ₁ * X1 + (1 - γ₁) * X2
    X3 = X2 + γ₁ * (X1 - X2)
    X3 = mod.(X3, Ω_sup)
    # conservation of momentum
    V3 = m1_over_m3 * V1 + m2_over_m3 * V2

    return (X3, V3)
end

function backward_react(X3, V3, p)
    (; ε, γ₀, one_minus_γ₀, Ω_sup, std_ζ, m1_over_m3, m2_over_m3) = p

    # displacement of positions
    # sample uniform rv in B(0,ε)
    Z = @SVector randn(3)
    U = rand()
    η = ε * cbrt(U) * (Z / norm(Z))

    # original equation
    # γ₀ * X1 + (1-γ₀) * X2 = X3
    # X1 - X2 = η
    X1 = X3 + one_minus_γ₀ * η
    X1 = mod.(X1, Ω_sup)
    X2 = X3 - γ₀ * η
    X2 = mod.(X2, Ω_sup)

    # displacement of velocities
    ζ = std_ζ * @SVector randn(3)
    # original equation
    # (m₁/m₃) * V1 + (m₂/m₃) * V2 = V3
    # V1 - V2 = ζ
    V1 = V3 + m2_over_m3 * ζ
    V2 = V3 - m1_over_m3 * ζ

    return (X1, V1, X2, V2)
end
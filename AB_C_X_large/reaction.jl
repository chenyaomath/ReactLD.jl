function backward_react(X3, p)
    (; ε, γ, one_minus_γ, Ω_sup) = p

    # displacement of positions
    # sample uniform rv in B(0,ε)
    Z = @SVector randn(3)
    U = rand()
    η = ε * cbrt(U) * (Z / norm(Z))

    # original equation
    # γ * X1 + (1-γ) * X2 = X3
    # X1 - X2 = η
    X1 = X3 + one_minus_γ * η
    if !all(0.0 .<= X1 .<= 200.0)
        X1 = mod.(X1, Ω_sup)
    end
    
    X2 = X3 - γ * η
    if !all(0.0 .<= X2 .<= 200.0)
        X2 = mod.(X2, Ω_sup)
    end

    return (X1, X2)
end
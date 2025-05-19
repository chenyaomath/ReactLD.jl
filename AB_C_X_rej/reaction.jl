function backward_react(X3, p)
    (; ε, γ, Ω_inf, Ω_sup) = p

    # displacement of positions
    # sample uniform rv in B(0,ε)
    Z = @SVector randn(3)
    U = rand()
    η = ε * cbrt(U) * (Z / norm(Z))

    # original equation
    # α * X1 + (1-α) * X2 = X3
    # X1 - X2 = η
    X1 = X3 + (1 - γ) * η
    X2 = X3 - γ * η

    products_outside = false

    # only update in the Ω
    X1_not_in_Ω = !all(Ω_inf <= elem <= Ω_sup for elem in X1)
    if X1_not_in_Ω
        products_outside = true
        return (products_outside, X1, X2)
        # else
        #   keep X1
    end

    # only update in the Ω
    X2_not_in_Ω = !all(Ω_inf <= elem <= Ω_sup for elem in X2)
    if X2_not_in_Ω
        products_outside = true
        return (products_outside, X1, X2)
        # else
        #   keep X2
    end

    return (products_outside, X1, X2)
end
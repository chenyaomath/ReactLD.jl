# ReactLD.jl

**ReactLD.jl** is a Julia package for performing stochastic simulations of particle-based **reactive Brownian and Langevin dynamics** using the Stochastic Simulation Algorithm (SSA).

This project focuses on the fundamental reversible reaction **A + B ⇌ C** but the methodology can be extended to more general reactions (see our paper below for details).

We consider randomly diffusing particles of species A, B, or C that evolve according to either:

**Brownian Dynamics (BDs):**
$$
      \dot{X}_t = \sqrt{2D} \dot{W}_t
$$

**Langevine Dynamics (LDs):**
$$
      \dot{X}_t = V_t, \quad \dot{V}_t = -\beta V_t + \beta \sqrt{2D} \dot{W}_t,
$$

where $X_t$ and $V_t$ denote positions and velocities of particles, $D$ is diffusion coefficient, and $\beta$ is the scaled friction constant.

## Quick Start

The repository contains several subfolders for running simulations of the A + B ⇌ C reaction:
* `AB_C_V_large/` and `AB_C_V_small/`: Langevin Dynamics simulations in large/small domains
* `AB_C_X_large/` and `AB_C_X_small/`: Brownian Dynamics simulations in large/small domains

To run a simulation, use the following command (customize the parameters as needed):
```zsh
nohup JULIA_NUM_THREADS=5 julia ReactLD.jl --num_sim 11000 --beta 1.0e19 --time_step 1.0e-7 > ABCV_sim11000_beta1.0e19_time_step1.0e-7_24072210.log 2>&1 &
```

## Main Results

| <img src="https://github.com/chenyaomath/ReactLD.jl/blob/main/AB_C_V_large/present/main_single_particle.png" width="400"/> | <img src="https://github.com/chenyaomath/ReactLD.jl/blob/main/AB_C_V_large/present/loss_single_particle.png" width="400"/> |
|:-------------------------------------------------------------------------------------------------------:|:-----------------------------------------------------------------------------------------------------------:|
| **Convergence of Reactive LDs to BDs** | **Error between Reactive LDs and BDs as β → ∞** |

## Support and citation
If you use this package in your work, please cite the following paper. Open-source development in academia depends heavily on proper attribution. Also, consider starring the repository—this helps us demonstrate impact and secure funding:

```perl
@misc{isaacson2025macroscopicallyconsistentreactivelangevin,
  title     = {A Macroscopically Consistent Reactive Langevin Dynamics Model},
  author    = {Samuel A. Isaacson and Qianhan Liu and Konstantinos Spiliopoulos and Chen Yao},
  year      = {2025},
  eprint    = {2501.09868},
  archivePrefix = {arXiv},
  primaryClass  = {physics.bio-ph},
  url       = {https://arxiv.org/abs/2501.09868}
}

```

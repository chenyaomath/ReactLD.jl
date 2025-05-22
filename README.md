# ReactLD.jl

This Julia project aims at performing stochastic simulation algorithm (SSA) of particle-based **reactive Brownian and Langevine dynamics**. 

In the project, we focus on the fundamental reaction A + B ⇌ C and the method can be extended to any abstract reactions (you can refer to our paper below).

We consider random particles with species A, B or C moving randomly following the Brownian Dynamics:

$\dot{X}_t = \sqrt{2D} \dot{W}_t$

and Langevine Dynamis:

$\dot{X}_t = V_t, \quad \dot{V}_t = -\beta V_t + \beta \sqrt{2D} \dot{W}_t$,

where $X_t$ and $V_t$ are positions and velocities of particles, $D$ is diffusion coefficient, and $\beta$ is the scaled friction constant.

## Quick Start

The folder AB_C_V_large and AB_C_V_small contains code for simulation of particles following reaction A + B ⇌ C with Langevine Dynamics (LDs) in a large/small domain

The folder AB_C_X_large and AB_C_X_small contains code for simulation of particles following reaction A + B ⇌ C with Brownian Dynamics (BDs) in a large/small domain.

You can repeat the simulation in each case by running the following command in your terminal:

```linux
nohup JULIA_NUM_THREADS=5 julia ReactLD.jl --num_sim 11000 --beta 1.0e19 --time_step 1.0e-7 > ABCV_sim11000_beta1.0e19_time_step1.0e-7_24072210.log 2>&1 &
```

## Main Results

| ![](https://github.com/chenyaomath/ReactLD.jl/blob/main/AB_C_V_large/present/main_single_particle.png) | ![](https://github.com/chenyaomath/ReactLD.jl/blob/main/AB_C_V_large/present/loss_single_particle.png) |
|:-------------:|:-------------:|
| Convergence of Reactive LDs to BDs | Error between Reactive LDs and BDs as β → ∞ |

## Support and citation
If you use this package for your work, we ask that you cite the following paper. Open source development as part of academic research strongly depends on this. Please also consider starring this repository if you like our work, this will help us to secure funding in the future.

```
@misc{isaacson2025macroscopicallyconsistentreactivelangevin,
      title={A Macroscopically Consistent Reactive Langevin Dynamics Model}, 
      author={Samuel A. Isaacson and Qianhan Liu and Konstantinos Spiliopoulos and Chen Yao},
      year={2025},
      eprint={2501.09868},
      archivePrefix={arXiv},
      primaryClass={physics.bio-ph},
      url={https://arxiv.org/abs/2501.09868}, 
}
```

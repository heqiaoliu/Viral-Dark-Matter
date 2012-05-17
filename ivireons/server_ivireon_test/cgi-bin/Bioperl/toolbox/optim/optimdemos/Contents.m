Optimization Toolbox 
%
% Demonstrations of large-scale methods.
%   circustent   - Quadratic programming to find shape of a circus tent.
%   molecule     - Molecule conformation solution using unconstrained nonlinear
%                  minimization.
%   optdeblur    - Image deblurring using bounded linear least-squares.
%   symbolic_optim_demo - Use symbolic toolbox functions to compute
%                         gradients and Hessians.
%
% Demonstrations of medium-scale methods.
%   tutdemo      - Tutorial walk-through.
%   goaldemo     - Goal attainment.
%   dfildemo     - Finite-precision filter design (requires Signal Processing
%                  Toolbox).
%   datdemo      - Fitting a curve to data.
%   officeassign - Binary integer programming to solve the office assignment
%                  problem.
%   bandem       - Banana function minimization demonstration.
%   airpollution - Use semi-infinite programming to analyze the effect of
%                  uncertainty.
% 
% Medium-scale examples from User's Guide
%   objfun       - nonlinear objective
%   confun       - nonlinear constraints
%   objfungrad   - nonlinear objective with gradient
%   confungrad   - nonlinear constraints with gradients
%   confuneq     - nonlinear equality constraints
%   optsim.mdl   - Simulink model of nonlinear plant process
%   optsiminit   - parameter initialization for optsim.mdl
%   bowlpeakfun  - objective function for parameter passing
%   nestedbowlpeak - nested objective function for parameter passing
%
% Large-scale examples from User's Guide
%   nlsf1         - nonlinear equations objective with Jacobian
%   nlsf1a        - nonlinear equations objective 
%   nlsdat1       - MAT-file of Jacobian sparsity pattern (see nlsf1a)
%   brownfgh      - nonlinear minimization objective with gradient and Hessian
%   brownfg       - nonlinear minimization objective with gradient 
%   brownhstr     - MAT-file of Hessian sparsity pattern (see brownfg)
%   browneq       - MAT-file of Aeq and beq sparse linear equality constraints
%   runfleq1      - demonstrates 'HessMult' option for FMINCON with equalities
%   brownvv       - nonlinear minimization with dense structured Hessian
%   hmfleq1       - Hessian matrix product for brownvv objective
%   fleq1         - MAT-file of V, Aeq, and beq for brownvv and hmfleq1 
%   qpbox1        - MAT-file of quadratic objective Hessian sparse matrix
%   runqpbox4     - demonstrates 'HessMult' option for QUADPROG with bounds
%   runqpbox4prec - demonstrates 'HessMult' and TolPCG options for QUADPROG
%   qpbox4        - MAT-file of quadratic programming problem matrices
%   runnls3       - demonstrates 'JacobMult' option for LSQNONLIN 
%   nlsmm3        - Jacobian multiply function for runnls3/nlsf3a objective
%   nlsdat3       - MAT-file of problem matrices for runnls3/nlsf3a objective
%   runqpeq5      - demonstrates 'HessMult' option for QUADPROG with equalities
%   qpeq5         - MAT-file of quadratic programming matrices for runqpeq5
%   particle      - MAT-file of linear least squares C and d sparse matrices
%   sc50b         - MAT-file of linear programming example
%   densecolumns  - MAT-file of linear programming example
%

% Internally Used Utility Routines
%
%   Demonstration utility routines
%   elimone           - eliminates a variable (used by dfildemo)
%   filtobj           - frequency response norm (used by dfildemo)
%   filtcon           - frequency response roots (used by dfildemo)
%   fitvector         - value of fitting function (used by datdemo)
%   tentdata          - MAT-file of data for circustent demo
%   optdeblur         - MAT-file of data for optdeblur demo
%   molecule          - MAT-file of data for molecule demo
%   mmole             - molecular distance problem (used by molecule demo)
%   plotdatapoints    - helper plotting function (used by datdemo)
%   printofficeassign - helper plotting function (used by officeassign demo)
%   filtfun           - returns frequency response and roots (used by dfildemo)
%   filtfun2          - returns frequency response norm and roots (used by dfildemo) 
%

%   Copyright 1990-2010 The MathWorks, Inc.
%   Generated from Contents.m_template revision 1.1.6.4.2.1  $Date: 2010/07/07 13:42:40 $


%% Creating IDNLGREY Model Files
% Grey box modeling is conceptually different to black box modeling in
% that it involves a more comprehensive modeling step. For IDNLGREY, the
% nonlinear counterpart of IDGREY, this step consists of creating a model
% file specifying the right-hand sides of the state and the output
% equations typically arrived at through physical first principle modeling.
% In this tutorial we will concentrate on general aspects on how to
% implement IDNLGREY m and C MEX model files.

%   Copyright 2005-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.8 $ $Date: 2010/03/26 17:24:09 $

%% IDNLGREY Model Files
% IDNLGREY supports estimation of parameters and initial states in
% nonlinear model structures written on the following explicit state-space
% form (so-called output-error, OE, form, named so as the noise e(t) only
% affects the output of the model structure in an additive manner):
%
%    xn(t) = F(t, x(t), u(t), p1, ..., pNpo);         x(0) = X0;
%     y(t) = H(t, x(t), u(t), p1, ..., pNpo) + e(t)
%
% For discrete-time structures, xn(t) = x(T+Ts) with Ts being the sampling
% time, and for continuous-time structures xn(t) = d/dt x(t). In addition,
% F(.) and H(.) are arbitrary linear or nonlinear functions with Nx (number
% of states) and Ny (number of outputs) components, respectively. Any of
% the model parameters p1, ..., pNpo as well as the initial state vector
% X(0) can be estimated. Worth stressing is that
%
%    1. time-series modeling, i.e., modeling without an exogenous input
%       signal u(t), and
%    2. static modeling, i.e., modeling without any states x(t)
%
% are two special cases that are supported by IDNLGREY. (See the tutorials
% idnlgreydemo3 and idnlgreydemo5 for examples of these two modeling
% categories).
                                                                  
%%
% The first IDNLGREY modeling step to perform is always to implement a
% MATLAB(R) or C MEX model file specifying how to update the states and
% compute the outputs. More to the point, the user must write a model file,
% MODFILENAME.m or MODFILENAME.c, defined with the following input and
% output arguments (notice that this form is required for both MATLAB and C
% MEX type of model files)
%
%   [dx, y] = MODFILENAME(t, x, u, p1, p2, ..., pNpo, FileArgument)
%
% MODFILENAME can here be any user chosen file name of a MATLAB or C
% MEX-file, e.g., see twotanks_m.m, pendulum_c.c etc. This file should be
% defined to return two outputs
%
%    dx: the right-hand side(s) of the state-space equation(s) (a column
%        vector with Nx real entries; [] for static models)
%     y: the right-hand side(s) of the output equation(s) (a column vector
%        with Ny real entries)
%
% and it should take 3+Npo(+1) input arguments specified as follows:
%
%     t: the current time
%     x: the state vector at time t ([] for static models)
%     u: the input vector at time t ([] for time-series models)
%     p1, p2, ..., pNpo: the individual parameters (which can be real
%        scalars, column vectors or 2-dimensional matrices); Npo is here
%        the number of parameter objects, which for models with scalar
%        parameters coincide with the number of parameters Np
%     FileArgument: optional inputs to the model file

%%
% In the onward discussion we will focus on writing model using either
% MATLAB language or using C-MEX files. However, IDNLGREY also supports
% P-files (protected MATLAB files obtained using the MATLAB command
% "pcode") and function handles. In fact, it is not only possible to use C
% MEX model files but also Fortran MEX files. Consult the MATLAB
% documentation on External Interfaces for more information about the
% latter.

%%
% What kind of model file should be implemented? The answer to this
% question really depends on the use of the model.
%
% Implementation using MATLAB language (resulting in a *.m file) has some
% distinct advantages. Firstly, one can avoid time-consuming, low-level
% programming and concentrate more on the modeling aspects. Secondly, any
% function available within MATLAB and its toolboxes can be used directly
% in the model files. Thirdly, such files will be smaller and, without any
% modifications, all built-in MATLAB error checking will automatically be
% enforced. In addition, this is obtained without any code compilation.
%
% C MEX modeling is much more involved and requires basic knowledge about
% the C programming language. The main advantage with C MEX model files is
% the improved execution speed. Our general advice is to pursue C MEX
% modeling when the model is going to be used many times, when large data
% sets are employed, and/or when the model structure contains a lot of
% computations. It is often worthwhile to start with using a MATLAB file
% and later on turn to the C MEX counterpart.

%% IDNLGREY Model Files Written Using MATLAB Language
% With this said, let us next move on to MATLAB file modeling and use a
% nonlinear second order model structure, describing a two tank system, as
% an example. See idnlgreydemo2 for the modeling details. The contents of
% twotanks_m.m are as follows.
type twotanks_m.m

%%
% In the function header, we here find the required t, x, and u input
% arguments followed by the six scalar model parameters, A1, k, a1, g, A2
% and a2. In the MATLAB file case, the last input argument should always be
% varargin to support the passing of an optional model file input argument,
% FileArgument. In an IDNLGREY model object, FileArgument is stored as a
% cell array that might hold any kind of data. The first element of
% FileArgument is here accessed through varargin{1}{1}.
%
% The variables and parameters are referred in the standard MATLAB way. The
% first state is x(1) and the second x(2), the input is u(1) (or just u in
% case it is scalar), and the scalar parameters are simply accessed through
% their names (A1, k, a1, g, A2 and a2). Individual elements of vector and
% matrix parameters are accessed as P(i) (element i of a vector parameter
% named P) and as P(i, j) (element at row i and column j of a matrix
% parameter named P), respectively.

%% IDNLGREY C MEX Model Files
% Writing a C MEX model file is more involved than writing a MATLAB model file.
% To simplify this step, it is recommended that the available IDNLGREY
% C MEX model template is copied to MODFILENAME.c. This template contains
% skeleton source code as well as detailed instructions on how to customize
% the code for a particular application. The location of the template file
% is found by typing the following at the MATLAB command prompt.
%
%    fullfile(matlabroot, 'toolbox', 'ident', 'nlident', 'IDNLGREY_MODEL_TEMPLATE.c')
%
% In "echodemo" mode, You can execute this command right away.

%%
% For the two tank example, this template was copied to twotanks_c.c. After
% some initial modifications and configurations (described below) the state
% and output equations were entered, thereby resulting in the following
% C MEX source code.
type twotanks_c.c

%%
% Let us go through the contents of this file. As a first observation, we
% can divide the work of writing a C MEX model file into four separate
% sub-steps, the last one being optional:
%
%    1. Inclusion of C-libraries and definitions of the number of outputs.
%    2. Writing the function computing the right-hand side(s) of the state
%       equation(s), compute_dx.
%    3. Writing the function computing the right-hand side(s) of the output
%       equation(s), compute_y.
%    4. Optionally updating the main interface function which includes
%       basic error checking functionality, code for creating and handling
%       input and output arguments, and calls to compute_dx and compute_y.

%%
% Before we address these sub-steps in more detail, let us briefly
% comment upon a couple of general features of the C programming language.
%
%    A. High-precision variables (all inputs, states, outputs and
%       parameters of an IDNLGREY object) should be defined to be of the
%       data type "double".
%    B. The unary * operator placed just in front of the variable or
%       parameter names is a so-called dereferencing operator. The
%       C-declaration "double *A1;" specifies that A1 is a pointer to a
%       double variable. The pointer construct is a concept within C that
%       is not always that easy to comprehend. Fortunately, if the
%       declarations of the output/input variables of compute_y and
%       compute_x are not changed and all unpacked model parameters are
%       internally declared with a *, then there is no need to know more
%       about pointers from an IDNLGREY modeling point of view.
%    C. Both compute_y and compute_dx are first declared and implemented,
%       where after they are called in the main interface function. In the
%       declaration, the keyword "void" states explicitly that no value is
%       to be returned.
%
% For further details of the C programming language we refer to the book
%
%     B.W. Kernighan and D. Ritchie. The C Programming Language, 2nd
%     edition, Prentice Hall, 1988.

%%
% 1. In the first sub-step we first include the C-libraries "mex.h"
% (required) and "math.h" (required for more advanced mathematics). The
% number of outputs is also declared per modeling file using a standard
% C-define:
%
%    /* Include libraries. */
%    #include "mex.h"
%    #include "math.h"
%
%    /* Specify the number of outputs here. */
%    #define NY 1
%
% If desired, one may also include more C-libraries than the ones above.

%%
% The "math.h" library must be included whenever any state or output
% equation contains more advanced mathematics, like trigonometric
% and square root functions. Below is a selected list of functions included
% in "math.h" and the counterpart found within MATLAB:
%
%    C-function              MATLAB function
%    ========================================
%    sin, cos, tan           sin, cos, tan
%    asin, acos, atan        asin, acos, atan   
%    sinh, cosh, tanh        sinh, cosh, tanh
%    exp, log, log10         exp, log, log10
%    pow(x, y)               x^y
%    sqrt                    sqrt
%    fabs                    abs
%
% Notice that the MATLAB functions are more versatile than the
% corresponding C-functions, e.g., the former handle complex numbers,
% while the latter do not.

%%
% 2-3. Next in the file we find the functions for updating the states,
% compute_dx, and the output, compute_y. Both these functions hold argument
% lists, with the output to be computed (dx or y) at position 1, after
% which follows all variables and parameters required to compute the
% right-hand side(s) of the state and the output equations, respectively.
%
% All parameters are contained in the parameter array p. The first step in
% compute_dx and compute_y is to unpack and name the parameters to be used
% in the subsequent equations. In twotanks_c.c, compute_dx declares six
% parameter variables whose values are determined accordingly:
%
%    /* Retrieve model parameters. */
%    double *A1, *k, *a1, *g, *A2, *a2;
%    A1 = p[0];   /* Upper tank area.        */
%    k  = p[1];   /* Pump constant.          */
%    a1 = p[2];   /* Upper tank outlet area. */
%    g  = p[3];   /* Gravity constant.       */
%    A2 = p[4];   /* Lower tank area.        */
%    a2 = p[5];   /* Lower tank outlet area. */
%
% compute_y on the other hand does not require any parameter for computing
% the output, and hence no model parameter is retrieved.

%%
% As is the case in C, the first element of an array is stored at position
% 0. Hence, dx[0] in C corresponds to dx(1) in MATLAB (or just dx in case
% it is a scalar), the input u[0] corresponds to u (or u(1)), the parameter
% A1[0] corresponds to A1, and so on.
%
% In the example above, we are only using scalar parameters, in which case
% the overall number of parameters Np equals the number of parameter
% objects Npo. If any vector or matrix parameter is included in the model,
% then Npo < Np.
%
% The scalar parameters are referenced as P[0] (P(1) or just P in a MATLAB
% file) and the i:th vector element as P[i-1] (P(i) in a MATLAB file). The
% matrices passed to a C MEX model file are different in the sense that the
% columns are stacked upon each other in the obvious order. Hence, if P is
% a 2-by-2 matrix, then P(1, 1) is referred as P[0], P(2, 1) as P[1],
% P(1, 2) as P[2] and P(2, 2) as P[3]. See "Tutorials on Nonlinear Grey Box
% Identification: An Industrial Three Degrees of Freedom Robot : C MEX-File
% Modeling of MIMO System Using Vector/Matrix Parameters", idnlgreydemo8,
% for an example where scalar, vector and matrix parameters are used.

%%
% The state and output update functions may also include other computations
% than just retrieving parameters and computing right-hand side
% expressions. For execution speed, one might, e.g., declare and use
% intermediate variables, whose values are used several times in the coming
% expressions. The robot tutorial mentioned above, idnlgreydemo8, is a good
% example in this respect.

%%
% compute_dx and compute_y are also able to handle an optional
% FileArgument. The FileArgument data is passed to these functions in the
% auxvar variable, so that the first component of FileArgument (a cell
% array) can be obtained through
%
%    mxArray* auxvar1 = mxGetCell(auxvar, 0);
%
% Here, mxArray is a MATLAB-defined data type that enables interchange of
% data between the C MEX-file and MATLAB. In turn, auxvar1 may contain any
% data. The parsing, checking and use of auxvar1 must be handled solely
% within these functions, where it is up to the model file designer to
% implement this functionality. Let us here just refer to the MATLAB
% documentation on External Interfaces for more information about functions
% that operate on mxArrays. An example of how to use optional C MEX model
% file arguments is provided in idnlgreydemo6, "Tutorials on Nonlinear Grey
% Box Identification: A Signal Transmission System : C MEX-File Modeling
% Using Optional Input Arguments".

%%
% 4. The main interface function should almost always have the same
% content and for most applications no modification whatsoever is needed.
% In principle, the only part that might be considered for changes is where
% the calls to compute_dx and compute_y are made. For static systems, one
% can leave out the call to compute_dx. In other situations, it might be
% desired to only pass the variables and parameters referred in the state
% and output equations. For example, in the output equation of the two tank
% system, where only one state is used, one could very well shorten the
% input argument list to
%
%    void compute_y(double *y, double *x)
%
% and call compute_y in the main interface function as
%
%    compute_y(y, x);

%%
% The input argument lists of compute_dx and compute_y might also be
% extended to include further variables inferred in the interface function.
% The following integer variables are computed and might therefore be
% passed on: nu (the number of inputs), nx (the number of states), and np
% (here the number of parameter objects). As an example, nx is passed to
% compute_y in the model investigated in the tutorial idnlgreydemo6.

%%
% The completed C MEX model file must be compiled before it can be used for
% IDNLGREY modeling. The compilation can readily be done from the MATLAB
% command line as
%
%    mex MODFILENAME.c
%
% Notice that the mex-command must be configured before it is used for the
% very first time. This is also achieved from the MATLAB command line via
%
%    mex -setup

%% IDNLGREY Model Object
% With an execution ready model file, it is straightforward to create
% IDNLGREY model objects for which simulations, parameter estimations, and
% so forth can be carried out. We exemplify this by creating two different
% IDNLGREY model objects for describing the two tank system, one using the
% model file written in MATLAB and one using the C MEX file detailed above
% (notice here that the C MEX model file has already been compiled).
Order         = [1 1 2];               % Model orders [ny nu nx].
Parameters    = [0.5; 0.003; 0.019; ...
                 9.81; 0.25; 0.016];   % Initial parameter vector.
InitialStates = [0; 0.1];              % Initial initial states.
nlgr_m    = idnlgrey('twotanks_m', Order, Parameters, InitialStates, 0)
nlgr_cmex = idnlgrey('twotanks_c', Order, Parameters, InitialStates, 0)

%% Conclusions
% In this tutorial we have discussed how to write IDNLGREY MATLAB and C MEX
% model files. We finally conclude the presentation by listing the
% currently available IDNLGREY model files and the tutorial/case study
% where they are being used. To simplify further comparisons, we list both
% the MATLAB (naming convention FILENAME_m.m) and the C MEX model files
% (naming convention FILENAME_c.c), and indicate in the tutorial column
% which type of modeling approach that is being employed in the tutorial or
% case study.
%
%    Tutorial/Case study       MATLAB file               C MEX-file
%    ======================================================================
%    idnlgreydemo1   (MATLAB)   dcmotor_m.m              dcmotor_c.c
%    idnlgreydemo2   (C MEX)    twotanks_m.m             twotanks_c.c
%    idnlgreydemo3   (MATLAB)   preys_m.m                preys_c.c
%                    (C MEX)    predprey1_m.m            predprey1_c.c
%                    (C MEX)    predprey2_m.m            predprey2_c.c
%    idnlgreydemo4   (MATLAB)   narendrali_m.m           narendrali_c.c
%    idnlgreydemo5   (MATLAB)   friction_m.m             friction_c.c
%    idnlgreydemo6   (C MEX)    signaltransmission_m.m   signaltransmission_c.c
%    idnlgreydemo7   (C MEX)    twobodies_m.m            twobodies_c.c
%    idnlgreydemo8   (C MEX)    robot_m.m                robot_c.c
%    idnlgreydemo9   (MATLAB)   cstr_m.m                 cstr_c.c
%    idnlgreydemo10  (MATLAB)   pendulum_m.m             pendulum_c.c
%    idnlgreydemo11  (C MEX)    vehicle_m.m              vehicle_c.c
%    idnlgreydemo12  (C MEX)    aero_m.m                 aero_c.c
%    idnlgreydemo13  (C MEX)    robotarm_m.m             robotarm_c.c
%
% The contents of these model files can be displayed in the MATLAB command
% window through the command "type FILENAME_m.m" or "type FILENAME_c.c".
% All model files are found in the directory returned by the following
% MATLAB command.
%
%    fullfile(matlabroot, 'toolbox', 'ident', 'iddemos', 'examples')

%% Additional Information
% For more information on identification of dynamic systems with System Identification Toolbox(TM) 
% visit the
% <http://www.mathworks.com/products/sysid/ System Identification Toolbox>
% product information page.

displayEndOfDemoMessage(mfilename)
%% Fixed-Point Arctangent Calculation
% Developing an efficient fixed-point arctangent algorithm to estimate an 
% angle is critical in many applications, including control of robotics,
% frequency tracking in wireless communications, and many more. This demo 
% shows how to use the CORDIC algorithm and polynomial approximation to do 
% a fixed-point calculation of the four quadrant inverse tangent. This
% implementation is equivalent to MATLAB(R) built-in function |atan2|, 
% which only supports floating-point data types. 
%
% |ATAN2(Y,X)| is the four quadrant arctangent of the real parts of the
% elements of X and Y, where $$ -\pi \leq atan2(y,x) \leq +\pi $$.
%
% Copyright 1999-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $

%% Calculating |atan2(y,x)| with the CORDIC Algorithm
%
% CORDIC is an acronym for COordinate Rotation DIgital Computer. 
% The Givens rotation-based CORDIC algorithm (see [1,2]) is among one of
% the most hardware efficient algorithms because it only requires 
% iterative shift-add operations. 
% The CORDIC algorithm is suitable for calculating
% a variety of functions, such as sine, cosine, arcsine, arccosine, 
% arctangent, vector magnitude, divide, square root, hyperbolic and 
% logarithmic functions. 
%
% Vectoring mode CORDIC equations are widely used to calculate |atan(y/x)|.
% In vectoring mode, the CORDIC rotator rotates the input vector towards
% the positive X-axis in order to minimize the  |y| component of the 
% residual vector. For each iteration, if the |y| coordinate of the 
% residual vector is positive, the CORDIC rotator will rotate using a 
% negative angle (clockwise); otherwise, it will rotate with a positive 
% angle (counter-clockwise). If the angle accumulator is initialized to 0,
% by the end of the iterations, the accumulated rotation angle is the 
% angle of the original input vector. 
%
% In vectoring mode, the CORDIC equations are: 
%
% $$ x_{i+1} = x_{i} - y_{i}*d_{i}*2^{-i} $$
%
% $$ y_{i+1} = y_{i} + x_{i}*d_{i}*2^{-i} $$
%
% $$ z_{i+1} = z_{i} + d_{i}*atan(2^{-i}) $$ is the angle accumulator
%
% where 
%   $$  d_{i} = +1 $$  if  $$ y_{i} < 0 $$, and $$ -1  $$ otherwise;
%
%   i = 0, 1, ..., N-1, and N is the total number of iterations.
%
% As N approaches $$ +\infty $$ :
%
% $$ x_{N} = A_{N}\sqrt{x_{0}^2+y_{0}^2} $$
%
% $$ y_{N} = 0 $$
%
% $$ z_{N} = z_{0} + atan(y_{0}/x_{0}) $$
%
% $$ A_{N} =
% 1/(cos(atan(2^{0}))*cos(atan(2^{-1}))*...*cos(atan(2^{-(N-1)}))) 
%  = \prod_{i=0}^{N-1}{\sqrt{1+2^{-2i}}}
%  $$
%
% As explained above, the arctangent can be directly 
% computed using the vectoring mode CORDIC rotator with the angle 
% accumulator being initialized to zero, 
% i.e., $$ z_{0}=0, $$ and $$ z_{N} \approx atan(y_{0}/x_{0}) $$.
%

%%
% *Floating-Point CORDIC Code*
%
% The floating-point CORDIC arctangent algorithm is implemented 
% in the |cordic_atan_fltpt.m| file.  This function 
% calculates arctangent in the range [-pi/2, pi/2] using the
% vectoring mode CORDIC algorithm. Both x and y must be real scalar 
% inputs, and x must be greater than or equal to 0. 
% The angle look-up table input is |angleLUT = atan(2.^-(0:N-1))|.
% The multiplication by negative powers of two can be done by using 
% the <matlab:doc('bitsra') bitsra> function that performs 
% arithmetic right bit shift operations. 

%% 
%   function [z, x, y] = cordic_atan_fltpt(y,x,N,angleLUT)
%   z = 0;
%   for i = 0:N-1,   
%       x0 = x;
%       if y < 0  % negative y leads to counter clock-wise rotation       
%           x = x0 - bitsra(y,i);  % x_{i+1} = x_{i} - y_{i}*2^{-i}
%           y = y + bitsra(x0,i);  % y_{i+1} = y_{i} + x_{i}*2^{-i}
%           z = z - angleLUT(i+1); % z_{i+1} = z_{i} + atan(2^{-i})       
%       else % positive y leads to clock-wise rotation              
%           x = x0 + bitsra(y,i);
%           y = y - bitsra(x0,i);
%           z = z + angleLUT(i+1); % z_{i+1} = z_{i} - atan(2^{-i})
%       end
%   end

%% Visualizing the Vectoring Mode CORDIC Iterations
%
% The CORDIC algorithm is guaranteed to converge, but not always 
% monotonically in a finite number of iterations. You can typically 
% achieve greater accuracy by increasing the number of iterations. 
% However, as you can see in the following example, intermediate 
% iterations occasionally rotate the vector closer to the positive X-axis 
% than the following iteration does. 
% Even so, the CORDIC algorithm is usually run through a specified number 
% of iterations. Ending the iterations early would break pipelined code, 
% and the gain $$ A_{n} $$ would not be constant because $$ n $$ 
% would vary.
%
% In the following example, iteration 5 provides a better estimate 
% of the angle than iteration 6, and the CORDIC algorithm converges 
% in later iterations. 
%
% Initialize the input vector with angle   $$ \theta = 43 $$ degrees, 
% magnitude = 1
origFormat = get(0, 'format'); %store original format setting;
                               % restore this at the end of the demo.
format short
%
theta = 43*pi/180; % Input angle in radians
Niter = 10;        % Ten iterations
inX = cos(theta);  % x coordinate of the input vector 
inY = sin(theta);  % y coordinate of the input vector 
% pre-allocate memories
zf = zeros(1, Niter);  
xf = [inX, zeros(1, Niter)];
yf = [inY, zeros(1, Niter)];
angleLUT = atan(2.^-(0:Niter-1)); %pre-calculate the angle look-up table
% Call floating-point CORDIC algorithm
for k = 1:Niter
   [zf(k), xf(k+1), yf(k+1)] = cordic_atan_fltpt(inY, inX, k, angleLUT); 
end

%%
% The following output shows the CORDIC angle accumulation (in degrees)
% through 10 iterations. Note that the 5th iteration produced less 
% error than the 6th iteration, and that the calculated angle quickly
% converged to the actual input angle after that.
angleAccumulator = zf*180/pi; angleError = angleAccumulator - theta*180/pi;
fprintf('Iteration: %2d, Calculated angle: %7.3f, Error in degrees: %10g, Error in bits: %g\n',...
        [(1:Niter); angleAccumulator(:)'; angleError(:)';log2(abs(zf(:)'-theta))]);
%%
% As N approaches $$ +\infty $$, the CORDIC rotator gain $$ A_{N} $$ 
% approaches 1.6476. In this example, the input $$ (x_{0},y_{0}) $$ was 
% on the unit circle, so the initial rotator magnitude is 1. The following
% output shows the rotator magnitude through 10 iterations:
rotatorMagnitude = sqrt(xf.^2+yf.^2); % CORDIC rotator gain through iterations
fprintf('Iteration: %2d, Rotator magnitude: %g\n',...
    [(0:Niter); rotatorMagnitude(:)']);
%%
% Note that $y_{n}$ approaches 0, and $x_{n}$ approaches 
% $$ A_{n} \sqrt{x_{0}^{2} + y_{0}^{2}} = A_{n}, $$ 
% because $$ \sqrt{x_{0}^{2} + y_{0}^{2}} = 1 $$.
y_n = yf(end)
%%
x_n = xf(end)
%%
figno = 1; 
fixpt_atan2_demo_plot(figno, xf, yf) %Vectoring Mode CORDIC Iterations
%%
figno = figno + 1; %Cumulative Angle and Rotator Magnitude Through Iterations
fixpt_atan2_demo_plot(figno,Niter, theta, angleAccumulator, rotatorMagnitude)
%%

%% Converting the Floating-Point CORDIC Algorithm to Fixed Point
%
% Compared with fixed-point calculations, floating-point calculations 
% have no overflow issues and suffer much less precision loss from
% rounding operations.
%
% To convert a floating-point algorithm to fixed point, we need to consider
% the hardware constraints, and the trade-offs between dynamic ranges and 
% finite precision. Assume the input and output word lengths are limited
% to 16 bits, and the dynamic range of the input is [-1, +1]. 
% Due to the CORDIC rotator gain, the dynamic range of the |x| and |y| 
% register is within (-2,+2). To avoid overflow, we pick a signed fixed 
% point input data type with a word length of 16 bits and a fraction length
% of 14 bits. This allows us to reuse the |x| and |y| registers in each
% CORDIC iteration. 
%
% Because the four quadrant CORDIC |atan2| algorithm outputs 
% estimated angles within  $$ [-\pi,  \pi] $$, we pick an output fraction 
% length of 13 bits to avoid overflow and provide a dynamic range of 
%  [-4, +3.9998779296875].  
%
% The fixed-point algorithm uses the default full precision mode of the 
% |fimath| object. When the numerator is a power-of-2 number, all division 
% operations are replaced by bitshift operations. 
%

originalGlobalFimath = fimath; % Save the current global fimath object
                               % so that it can be restored at the end of the demo.
% Specify and set the global fimath to be used in this demo. 
% To produce efficient code, Floor rounding and wrap overflow are used.
F = fimath('RoundMode',    'floor', ...
           'OverflowMode', 'wrap', ...
           'ProductMode',  'FullPrecision', ...
           'SumMode',      'FullPrecision');
globalfimath(F);   

%%
% *CORDIC Rotator Gain*
%
% Although the CORDIC rotator gain $$ A_{N} $$ does not affect the final
% calculated angle, it does affect the intermediate quantities. 
% Thus, to avoid overflow, the CORDIC rotator gain needs to be considered
% when selecting fraction lengths for the input and output data types 
% during fixed-point algorithm development. The gain $$ A_{N} $$ is a 
% constant for a given N, and quickly approaches a value of 1.64676. Thus, 
% because the gain is always greater than 1 and less than 2, only one extra
% bit needs to be added to account for the growth in fixed-point algorithms.
% The following code shows the CORDIC rotator gain $$ A_{N} $$ 
% for N=0 through N=16, where N=0 corresponds to no rotations.
for N=0:16
    A = prod(sqrt(1+2.^(-2*(0:N-1))));
    fprintf('A_%2d = %.14f\n',N,A)
end                             

%%
% *Fixed-Point Algorithm*
%
% Because the <matlab:doc('bitsra') bitsra> function supports double, 
% single, integer and fixed-point numeric types, a shared CORDIC 
% arctangent algorithm is implemented in the |cordic_atan_kernel.m| file. 
% It supports both floating-point and fixed-point numeric types. 
% The shared fixed-point and floating-point algorithm is obtained by 
% minor updates of the floating-point CORDIC code. 
%
% For fixed-point operations, the |bitsra| function ignores the 
% |OverflowMode| and |RoundMode| properties.
% All other fixed-point arithmetic operations performed through out this 
% algorithm are done according to the properties of the global fimath, 
% the RoundMode of which is set to floor for efficiency because no bits 
% will be rounded off in addition.

%   function [z,x,y] = cordic_atan_kernel(y,x,N,angleLUT)
%   z = angleLUT(1); z(:) = 0; % z has the same data type as angleLUT
%   for i = 0:N-1,    
%       x0 = x;
%       if y < 0 % negative y leads to counter clock-wise rotation
%           x(:) = x0 - bitsra(y,i);
%           y(:) = y + bitsra(x0,i);
%           z(:) = z - angleLUT(i+1); % z_{i+1} = z_{i} + atan(2^{-i})
%       else  % positive y leads to clock-wise rotation 
%           x(:) = x0 + bitsra(y,i);
%           y(:) = y - bitsra(x0,i);
%           z(:) = z + angleLUT(i+1); % z_{i+1} = z_{i} - atan(2^{-i})
%       end
%   end

%%
% *Four-Quadrant CORDIC*
%
% The four quadrant CORDIC |atan2| algorithm is implemented in the 
% |cordic_atan2.m| file.  It uses the 2-quadrant arctangent algorithm by
% passing in abs(x), and then using angle correction to calculate the 
% second and third quadrant results.
%
%   function z = cordic_atan2(y,x,N)
%   if isfi(y)
%     % Fixed-point
%     Ty = numerictype(y);
%     Tz = numerictype(1, Ty.WordLength, Ty.WordLength - 3);
%     % Build the constant angle look-up-table. Because a local fimath is not 
%     % specified for the fi object 'angleLUT', it is created using the default 
%     % RoundMode of nearest and OverflowMode of saturate.
%     angleLUT = fi(atan(2.^-(0:N-1)), Tz);
%     z = fi(zeros(size(y)),Tz); 
%   else
%     % Floating-point
%     angleLUT = atan(2.^-(0:N-1));
%     z = zeros(size(y));
%   end
% 
%   for k = 1:length(y)
%       z(k) = cordic_atan_kernel(y(k),abs(x(k)),N,angleLUT);
%   end
%
%   for k = 1:length(y)  
%     % Correct for second and third quadrant
%     if x(k) < 0 
%         if y(k) >= 0
%             % Second quadrant
%             z(k) =  pi - z(k);
%         else
%             % Third quadrant
%             z(k) = -pi - z(k);
%         end    
%     end
%   end

%% Performing Overall Error Analysis of the CORDIC Algorithm
% The overall error consists of two parts:
%
% # The algorithmic error that results from the CORDIC rotation angle
%    being represented by a finite number of basic angles.
% # The quantization or rounding error that results from the finite 
%    precision representation of the angle look-up table, and the finite 
%    precision arithmetic used in fixed-point operations.

%% 
% *Calculate the CORDIC Algorithmic Error*
%
theta = (-178:2:180)*pi/180; % angle in radians
inXflt = cos(theta); % generates input vector
inYflt = sin(theta);
Niter = 12; % total number of iterations
zflt = cordic_atan2(inYflt, inXflt, Niter); % floating-point algorithm
%% 
% Calculate the maximum magnitude of the CORDIC algorithmic error by 
% comparing the CORDIC computation to the builtin |atan2| function.
format long
cordic_algErr_real_world_value = max(abs((atan2(inYflt, inXflt) - zflt)))
%%
% The log base 2 error is related to the number of iterations.  In this
% example, we use 12 iterations and are accurate to 11 binary digits, so 
% the magnitude of the error is less than $$ 2^{-11} $$
cordic_algErr_bits = log2(cordic_algErr_real_world_value)

%%
% *Calculate the CORDIC Overall Error*
%
% _The Effect of Rounding Modes in CORDIC_
%
% Typically, |Convergent|, |Round| and |Nearest| rounding modes give better
% results than other rounding modes like |Floor|, |Ceil| and |Fix|.  
% The sums and differences in the CORDIC algorithm are all done in full 
% precision because all binary points are identical and we scaled the 
% input such that it will never overflow.  Similar to the |>>| operator in 
% C, the |bitsra| operation used in the CORDIC algorithm shifts the bits 
% of the operand to the right. Excess bits are shifted off the right side 
% and discarded without regard to rounding mode.  Hence, the rounding mode 
% has no effect on fixed-point math in the CORDIC algorithm.  
%
% The only place that a more expensive rounding mode can increase precision
% in the CORDIC algorithm is in the building of the angle look-up table.  
% In the |cordic_atan2| function, we chose to use |Nearest| rounding 
% to build the constant angle look-up table at initialization time, and 
% then used |Floor| rounding to improve efficiency at run time.
%
%%
% _Relationship Between Number of Iterations and Precision_
%
% Once the quantization error dominates the overall error, i.e., the 
% quantization error is greater than the algorithmic error, increasing the 
% total number of iterations won't significantly decrease the overall 
% error of the fixed-point CORDIC algorithm. 
% 
% It is recommended that you pick your fraction lengths and total number 
% of iterations to ensure that the quantization error is smaller than the 
% algorithmic error.  In the CORDIC algorithm, the precision increases by 
% one bit every iteration. Thus, there is no reason to pick a number of 
% iterations greater than the precision of the input data.  
% Another way to look at the relationship between the number of iterations
% and the precision, is in the right-shift step of the algorithm.  
% For example, on the counter-clockwise rotation
%
%  x(:) = x0 - bitsra(y,i); 
%  y(:) = y + bitsra(x0,i); 
%
% if i is equal to the word-length of y and x0, then |bitsra(y,i)| and
% |bitsra(x0,i)| shift all the way to zero and do not contribute 
% anything to the next step.
%
% To ensure that we only measure the error from the fixed-point algorithm, 
% and not the differences in input values, the floating-point reference is 
% computed with the same inputs as the fixed-point CORDIC algorithm.

inXfix = sfi(inXflt, 16, 14);
inYfix = sfi(inYflt, 16, 14);

zref = atan2(double(inYfix), double(inXfix));
zfix8 = cordic_atan2(inYfix, inXfix, 8);
zfix10 = cordic_atan2(inYfix, inXfix, 10);
zfix12 = cordic_atan2(inYfix, inXfix, 12);
zfix14 = cordic_atan2(inYfix, inXfix, 14);
zfix15 = cordic_atan2(inYfix, inXfix, 15);
cordic_err = bsxfun(@minus,zref,double([zfix8;zfix10;zfix12;zfix14;zfix15]));

%%
% The error depends on the number of iterations and the precision of
% the input data.  In this example, the input data is in the range [-1, +1], 
% and the number of fractional bits is 14.  From the following tables 
% showing the maximum error at each iteration, and the figure showing the 
% overall error of the CORDIC algorithm, you can see that the error 
% decreases by about 1 bit per iteration until the precision of the data 
% is reached.

iterations = [8, 10, 12, 14, 15];
max_cordicErr_real_world_value = max(abs(cordic_err'));
fprintf('Iterations: %2d, Max error in real-world-value: %g\n',...
    [iterations; max_cordicErr_real_world_value]);
%%
max_cordicErr_bits = log2(max_cordicErr_real_world_value);
fprintf('Iterations: %2d, Max error in bits: %g\n',[iterations; max_cordicErr_bits]);
%%
figno = figno + 1; 
fixpt_atan2_demo_plot(figno, theta, cordic_err)

%% Accelerating the Fixed-Point CORDIC Algorithm Using |emlmex|
% 
% A C-MEX function can be generated from MATLAB code using the 
% Embedded MATLAB(R) <matlab:doc('emlmex') emlmex> command. Typically, 
% running the generated C-MEX function can improve the simulation speed 
% (see [3]). The actual speed improvement depends on the simulation 
% platform being used. The following example shows how to accelerate 
% the fixed-point CORDIC |atan2| algorithm using |emlmex|.
%
% The |emlmex| function compiles the MATLAB code into a C-MEX function. 
% This step requires the creation of a temporary directory 
% and write permissions in this directory.
emlmexdir = [tempdir 'emlmexdir'];
if ~exist(emlmexdir,'dir')
    mkdir(emlmexdir);
end
emlcurdir = pwd;
cd(emlmexdir)
%%
% Compile |cordic_atan2| into a C-MEX file.  When you
% declare the number of iterations to be a constant (e.g., |12|) using 
% |emlcoder.egc(12)|, the angle look-up table will also be constant, and 
% thus won't be computed at each iteration.  Also, when you call 
% |cordic_atan2_mex|, you no longer need to give it the input argument for
% the number of iterations.  If you do try to pass in the number of
% iterations, the mex-function will error.
% 
% The data type of the input parameters determines whether the 
% |cordic_atan2| function performs fixed-point or floating-point 
% calculations. When the Embedded MATLAB subset generates code for this 
% file, code is only generated for the specific data type.  In other words, 
% if the inputs are fixed point, only fixed-point code is generated.
%
inp = {inYfix, inXfix, emlcoder.egc(12)}; %Example inputs for the function
emlmex('cordic_atan2', '-o', 'cordic_atan2_mex',  '-eg', inp)
%%
% First, calculate a vector of 4 quadrant |atan2| by calling  
% |cordic_atan2|.
tstart = tic; 
cordic_atan2(inYfix,inXfix,Niter);
telapsed_Mcordic_atan2 = toc(tstart);
%%
% Next, calculate a vector of 4 quadrant |atan2| by calling the
% MEX-function |cordic_atan2_mex|
cordic_atan2_mex(inYfix,inXfix); % load the C-MEX file
tstart = tic; 
cordic_atan2_mex(inYfix,inXfix);
telapsed_MEXcordic_atan2 = toc(tstart);
%%
% Now, compare the speed. Type the following in the MATLAB command window 
% to see the speed improvement on your specific platform:

emlmex_speedup = telapsed_Mcordic_atan2/telapsed_MEXcordic_atan2;

%%
% To clean up the temporary directory, run the following commands:
cd(emlcurdir);
clear cordic_atan2_mex;
status = rmdir(emlmexdir,'s');

%% Calculating |atan2(y,x)| Using Chebyshev Polynomial Approximation
%
% Polynomial approximation is a Multiply ACcumulation (MAC) centric 
% algorithm. It can be a good choice for DSP implementations of  
% non-linear functions like |atan(x)|.
%
% For a given degree of polynomial, and a given function |f(x) = atan(x)| 
% evaluated over the interval of [-1, +1], the polynomial approximation 
% theory tries to find the polynomial that minimizes the maximum value 
% of $$ |P(x)-f(x)| $$, where |P(x)| is the approximating polynomial. In 
% general, one can obtain polynomials very close to the optimal one by 
% approximating the given function in terms of Chebyshev polynomials and 
% cutting off the polynomial at the desired degree.
%
% The approximation of arctangent over the interval of [-1, +1] using
% the Chebyshev polynomial of the first kind is summarized in the following
% formula:
%
% $$ atan(x) = 2\sum_{n=0}^{\infty} {(-1)^{n}q^{2n+1} \over (2n+1)}
% T_{2n+1}(x) $$
%
% where 
%
% $$ q = 1/(1+\sqrt{2}) $$ 
%
% $$ x \in [-1, +1] $$ 
% 
% $$ T_{0}(x) = 1 $$
%
% $$ T_{1}(x) = x $$
%
% $$ T_{n+1}(x) = 2xT_{n}(x) - T_{n-1}(x). $$
%
% Therefore, the 3rd order Chebyshev polynomial approximation is 
% 
% $$ atan(x) = 0.970562748477141*x - 0.189514164974601*x^{3}. $$
%
% The 5th order Chebyshev polynomial approximation is 
%
% $$ atan(x) = 0.994949366116654*x - 0.287060635532652*x^{3} 
%    + 0.078037176446441*x^{5}. $$
%
% The 7th order Chebyshev polynomial approximation is 
%
% $$ \begin{array}{lllll}
%  atan(x) & = & 0.999133448222780*x     & - & 0.320533292381664*x^{3} \\
%          & + & 0.144982490144465*x^{5} & - & 0.038254464970299*x^{7}.
% \end{array} $$
%
% You can obtain four quadrant output through angle correction based on the 
% properties of the arctangent function.

 
%% Comparing the Algorithmic Error of the CORDIC and Polynomial Approximation Algorithms
%
% In general, higher degrees of polynomial approximation produce more 
% accurate final results. However, higher degrees of polynomial
% approximation also increase the complexity of the algorithm and require 
% more MAC operations and more memory. To be consistent with the CORDIC
% algorithm and the MATLAB |atan2| function, the input arguments 
% consist of both |x| and |y| coordinates instead of the ratio |y/x|.
%
% To eliminate quantization error, floating-point implementations of the 
% CORDIC and Chebyshev polynomial approximation algorithms are used in the
% comparison. An algorithmic error comparison reveals that increasing the 
% number of CORDIC iterations results in less error. It also reveals that 
% the CORDIC algorithm with 12 iterations provides a slightly better angle 
% estimation than the 5th order Chebyshev polynomial approximation. The
% approximation error of the 3rd order Chebyshev Polynomial is about 8 
% times bigger than that of the 5th order Chebyshev polynomial. The order 
% or degree of the polynomial can be chosen based on the required accuracy 
% of the angle estimation and the hardware constraints.
%
% The coefficients of the Chebyshev polynomial approximation for |atan(x)|, 
% are shown in ascending order of |x|.

constA3 = [0.970562748477141, -0.189514164974601]; % 3rd order
constA5 = [0.994949366116654,-0.287060635532652,0.078037176446441]; %5th order
constA7 = [0.999133448222780 -0.320533292381664 0.144982490144465...
          -0.038254464970299]; %7th order
      
theta = (-90:1:90)*pi/180; % angle in radians
inXflt = cos(theta);
inYflt = sin(theta);    
zfltRef = atan2(inYflt, inXflt); %Ideal output from ATAN2 function
zfltp3 =  poly_atan2(inYflt,inXflt,3,constA3);  % 3rd order   
zfltp5 =  poly_atan2(inYflt,inXflt,5,constA5);  % 5th order 
zfltp7 =  poly_atan2(inYflt,inXflt,7,constA7);  % 7th order 
poly_algErr = [zfltRef;zfltRef;zfltRef] - [zfltp3;zfltp5;zfltp7]; 

zflt8 = cordic_atan2(inYflt, inXflt, 8); % Cordic Alg with 8 iterations
zflt12 = cordic_atan2(inYflt, inXflt, 12); % Cordic Alg with 12 iterations
cordic_algErr = [zfltRef;zfltRef] - [zflt8;zflt12];

%%
% The maximum algorithmic error magnitude (or infinity norm of the 
% algorithmic error) for the CORDIC algorithm with 8 and 12 iterations 
% is shown below:
max_cordicAlgErr = max(abs(cordic_algErr'));
fprintf('Iterations: %2d, CORDIC algorithmic error in real-world-value: %g\n',...
    [[8,12]; max_cordicAlgErr(:)']);
%%
% The log base 2 error shows the number of binary digits of accuracy. The
% 12th iteration of the CORDIC algorithm has an estimated angle accuracy of
% $$ 2^{-11} $$:
max_cordicAlgErr_bits = log2(max_cordicAlgErr);
fprintf('Iterations: %2d, CORDIC algorithmic error in bits: %g\n',...
    [[8,12]; max_cordicAlgErr_bits(:)']);
%%
% The following code shows the magnitude of the maximum algorithmic error 
% of the polynomial approximation for orders 3, 5, and 7:
max_polyAlgErr = max(abs(poly_algErr'));
fprintf('Order: %d, Polynomial approximation algorithmic error in real-world-value: %g\n',...
    [3:2:7; max_polyAlgErr(:)']);
%%
% The log base 2 error shows the number of binary digits of accuracy.
max_polyAlgErr_bits = log2(max_polyAlgErr);
fprintf('Order: %d, Polynomial approximation algorithmic error in bits: %g\n',...
    [3:2:7; max_polyAlgErr_bits(:)']);

%%
figno = figno + 1; 
fixpt_atan2_demo_plot(figno, theta, cordic_algErr, poly_algErr)

%% Converting the Floating-Point Chebyshev Polynomial Approximation Algorithm to Fixed Point
%
% Assume the input and output word lengths are constrained to 16 bits by 
% the hardware, and the 5th order Chebyshev polynomial is used in the 
% approximation. Because the dynamic range of inputs  |x|, |y| and |y/x|
% are all within [-1, +1], we can avoid overflow by picking a signed 
% fixed-point input data type with a word length of 16 bits and a fraction 
% length of 14 bits. The coefficients of the polynomial are purely 
% fractional and within (-1, +1), so we can pick their data types as 
% signed fixed point with a word length of 16 bits and a fraction length 
% of 15 bits (best precision). The algorithm is robust because  
% $$ (y/x)^{n} $$ is within [-1, +1], and the multiplication of the 
% coefficients and  $$ (y/x)^{n} $$ is within (-1, +1). Thus, the dynamic 
% range won't grow, and because of the pre-determined fixed-point data 
% types, overflow is not expected.
%
% Similar to the CORDIC algorithm, the four quadrant polynomial 
% approximation-based |atan2| algorithm outputs estimated angles within 
% $$ [-\pi,  \pi] $$. Therefore, we can pick an output fraction length of 
% 13 bits to avoid overflow and provide a dynamic range of 
% [-4, +3.9998779296875]. 
% 
%% 
% The basic floating-point Chebyshev polynomial approximation of arctangent 
% over the interval [-1, +1] is implemented in the |chebyPoly_atan_fltpt.m| 
% file.
%
%     function z = chebyPoly_atan_fltpt(y,x,N,constA,Tz)
% 
%     tmp = y/x;
%     switch N
%         case 3
%             z = constA(1)*tmp + constA(2)*tmp^3;
%         case 5
%             z = constA(1)*tmp + constA(2)*tmp^3 + constA(3)*tmp^5;
%         case 7
%             z = constA(1)*tmp + constA(2)*tmp^3 + constA(3)*tmp^5 + constA(4)*tmp^7;
%         otherwise
%             disp('Supported order of Chebyshev polynomials are 3, 5 and 7');
%     end 

%%
% The basic fixed-point Chebyshev polynomial approximation of arctangent 
% over the interval [-1, +1] is implemented in the |chebyPoly_atan_fixpt.m| 
% file. 
%
%     function z = chebyPoly_atan_fixpt(y,x,N,constA,Tz)
%     
%     z = fi(0,'NumericType', Tz);
%     Tx = numerictype(x);
%     tmp = fi(0, 'NumericType',Tx);
%     tmp(:) = Tx.divide(y, x); % y/x;
% 
%     tmp2 = fi(0, 'NumericType',Tx);
%     tmp3 = fi(0, 'NumericType',Tx);  
%     tmp2(:) = tmp*tmp;  % (y/x)^2
%     tmp3(:) = tmp2*tmp; % (y/x)^3
%     z(:) = constA(1)*tmp + constA(2)*tmp3; % for order N = 3
% 
%     if (N == 5) || (N == 7)
%         tmp5 = fi(0, 'NumericType',Tx);
%         tmp5(:) = tmp3 * tmp2; % (y/x)^5
%         z(:) = z + constA(3)*tmp5; % for order N = 5
%         if N == 7
%             tmp7 =  fi(0, 'NumericType',Tx);
%             tmp7(:) = tmp5 * tmp2; % (y/x)^7
%             z(:) = z + constA(4)*tmp7; %for order N = 7
%         end   
%     end
     
%%
% The universal four quadrant |atan2| calculation using Chebyshev 
% polynomial approximation is implemented in the |poly_atan2.m| file. 
%
%     function z = poly_atan2(y,x,N,constA,Tz)
%     
%      if nargin<5, 
%         % floating-point algorithm
%         fhandle = @chebyPoly_atan_fltpt;
%         Tz = [];
%         z = zeros(size(y));
%      else
%         % fixed-point algorithm
%         fhandle = @chebyPoly_atan_fixpt;
%         %pre-allocate output
%         z = fi(zeros(size(y)), 'NumericType', Tz);
%     end
% 
%     for idx = 1:length(y)  
%        % fist quadrant 
%        if abs(x(idx)) >= abs(y(idx)) 
%            % (0, pi/4]
%            z(idx) = feval(fhandle, abs(y(idx)), abs(x(idx)), N, constA, Tz);
%        else
%            % (pi/4, pi/2)
%            z(idx) = pi/2 - feval(fhandle, abs(x(idx)), abs(y(idx)), N, constA, Tz);
%        end
% 
%        if x(idx) < 0 
%             % second and third quadrant
%             if y(idx) < 0
%               z(idx) = -pi + z(idx);
%             else
%               z(idx) = pi - z(idx);
%             end      
%        else % fourth quadrant
%            if y(idx) < 0
%                z(idx) = -z(idx);
%            end
%        end
%     end

%% Performing the Overall Error Analysis of the Polynomial Approximation Algorithm
%
% Similar to the CORDIC algorithm, the overall error of the polynomial 
% approximation algorithm consists of two parts, i.e., the algorithmic
% error and the quantization error. The algorithmic error of the polynomial 
% approximation algorithm was analyzed and compared to the algorithmic 
% error of the CORDIC algorithm in a previous section.

%%
% *Calculate the Quantization Error*
%
% The quantization error is computed by comparing the fixed-point 
% polynomial approximation to the floating-point polynomial approximation.
%
F = fimath('RoundMode','Floor','OverflowMode','Saturate');
globalfimath(F);
% Quantize the inputs and coefficients with convergent rounding
% Then, associate the fi objects with the global fimath by 
% removing their local fimath properties
inXfix = fi(fi(inXflt, 1, 16, 14,'RoundMode','Convergent'),'fimath',[]);
inYfix = fi(fi(inYflt, 1, 16, 14,'RoundMode','Convergent'),'fimath',[]);
constAfix3 = fi(fi(constA3, 1, 16,'RoundMode','Convergent'),'fimath',[]); 
constAfix5 = fi(fi(constA5, 1, 16,'RoundMode','Convergent'),'fimath',[]); 
constAfix7 = fi(fi(constA7, 1, 16,'RoundMode','Convergent'),'fimath',[]);

Tz = numerictype(1, 16, 13); % output data type
zfix3p =  poly_atan2(inYfix,inXfix,3,constAfix3,Tz);  % 3rd order   
zfix5p =  poly_atan2(inYfix,inXfix,5,constAfix5,Tz);  % 5th order 
zfix7p =  poly_atan2(inYfix,inXfix,7,constAfix7,Tz);  % 7th order 
poly_quantErr = bsxfun(@minus, [zfltp3;zfltp5;zfltp7], double([zfix3p;zfix5p;zfix7p]));
%  
polyOrder = 3:2:7;
max_polyQuantErr_real_world_value = max(abs(poly_quantErr'));
max_polyQuantErr_bits = log2(max_polyQuantErr_real_world_value);
fprintf('PolyOrder: %2d, Quant error in bits: %g\n',...
    [polyOrder; max_polyQuantErr_bits]);
%% 
% *Calculate the Overall Error*
%
% The overall error is computed by comparing the fixed-point polynomial
% approximation to the builtin |atan2| function. The ideal reference 
% output is |zfltRef|. The overall error of the 7th order polynomial
% approximation is dominated by the quantization error, which is due
% to the finite precision of the input data, coefficients and the rounding
% effects from the fixed-point arithmetic operations.
poly_err = bsxfun(@minus, zfltRef, double([zfix3p;zfix5p;zfix7p])); 
max_polyErr_real_world_value = max(abs(poly_err'));
max_polyErr_bits = log2(max_polyErr_real_world_value);
fprintf('PolyOrder: %2d, Overall error in bits: %g\n',...
    [polyOrder; max_polyErr_bits]);
%%
figno = figno + 1; 
fixpt_atan2_demo_plot(figno, theta, poly_err)

%%
% *The Effect of Rounding Modes in Polynomial Approximation*
%
% Compared to the CORDIC algorithm with 12 iterations and a 13 bit 
% fraction length in the angle accumulator, the fifth order Chebyshev 
% polynomial approximation gives a similar order of quantization error.
% In the following example, |Nearest|, |Round| and |Convergent| 
% rounding modes give smaller quantization error than 
% the |Floor| rounding mode.
% 
% Maximum magnitude of the quantization error using |Floor| rounding
poly5_quantErrFloor = max(abs(poly_quantErr(2,:)));
poly5_quantErrFloor_bits = log2(poly5_quantErrFloor)

%%
% For comparison, calculate the maximum magnitude of the quantization error 
% using |Nearest| rounding.
F = fimath('RoundMode','Nearest','OverflowMode','Saturate');
globalfimath(F);
zfixp5n = poly_atan2(inYfix,inXfix,5,constAfix5, Tz);
poly5_quantErrNearest = max(abs(zfltp5 - double(zfixp5n)));
poly5_quantErrNearest_bits = log2(poly5_quantErrNearest)

%% Comparing the Costs of the Fixed-Point CORDIC and Polynomial Approximation Algorithms
%
% The fixed-point CORDIC algorithm requires the following operations *per
% iteration*:
%%
% * 1 table lookup
% * 2 shifts
% * 3 additions
%%
% As a comparison, the N-th order fixed-point Chebyshev polynomial 
% approximation algorithm requires the following operations:
%%
% * 1 division (only required if the ratio is not available as an input)
% * (N+1) multiplications
% * (N-1)/2 additions
%
% In real world applications, selecting an algorithm for the fixed-point
% arctangent calculation typically depends on the required accuracy, cost 
% and hardware constraints.

% Reset the global fimath to the original global fimath
globalfimath(originalGlobalFimath); 
set(0, 'format', origFormat); %reset MATLAB output format
close all;

%% References
%
% # Jack E. Volder, The CORDIC Trigonometric Computing Technique, IRE
% Transactions on Electronic Computers, Volume EC-8, September 1959,
% pp330-334.
% # Ray Andraka, A survey of CORDIC algorithm for FPGA based computers,
% Proceedings of the 1998 ACM/SIGDA sixth international symposium on Field
% programmable gate arrays, Feb. 22-24, 1998, pp191-200
% # Speeding Up Fixed-Point Execution with the emlmex Function, 
% in section "Working with the Fixed-Point Embedded MATLAB Subset" of 
% Fixed-Point Toolbox(TM) User's Guide 

displayEndOfDemoMessage(mfilename)

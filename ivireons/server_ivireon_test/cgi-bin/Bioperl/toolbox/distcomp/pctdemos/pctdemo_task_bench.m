function times = pctdemo_task_bench(count)
%PCTDEMO_TASK_BENCH  MATLAB Benchmark modified for the Parallel Computing
%Toolbox demos.
% 
%   PCTDEMO_TASK_BENCH times four different MATLAB operations and
%   compares the execution speed.  The four operations are:
%   
%    LU       LAPACK, n = 1000.        Floating point, regular memory access.
%    FFT      Fast Fourier Transform.  Floating point, irregular memory access.
%    ODE      Ordinary diff. eqn.      Data structures and MATLAB files.
%    Sparse   Solve sparse system.     Mixed integer and floating point.
%
%   See also BENCH

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/03/22 03:42:39 $
    
    if nargin < 1
        count = 1; 
    end;
    times = zeros(count, 4);
    % Use a private stream to avoid resetting the global stream
    stream = RandStream('mt19937ar');
    
    for k = 1:count
       % LU, n = 1000.
       lu(0);
       n = 1000;
       reset(stream, 0);
       A = randn(stream, n, n);
       X = A; %#ok Used to preallocate X.
       clear X
       tic
          X = lu(A); %#ok Result not used -- strictly for timing.
       times(k, 1) = toc;
       clear A
       clear X
       
       fft(0);
       n = 2^20;
       y = ones(1, n)+ i*ones(1, n); %#ok Used to preallocate y.
       clear y
       reset(stream, 1);
       x = randn(stream, 1, n);
       tic
          y = fft(x); %#ok Result not used -- strictly for timing.
          clear y
          y = fft(x); %#ok Result not used -- strictly for timing.
       times(k, 2) = toc;
       clear x
       clear y
       
       % ODE. van der Pol equation, mu = 1
       
       F = @vdp1;
       y0 = [2; 0];
       tspan = [0 eps];
       [s, y] = ode45(F, tspan, y0); %#ok Used to preallocate s and y.
       tspan = [0 400];
       tic
          [s, y] = ode45(F, tspan, y0);%#ok Results not used -- strictly for timing.
       times(k, 3) = toc;
       clear s y
       
       % Sparse linear equations.
       
       n = 120;
       A = delsq(numgrid('L', n));
       b = sum(A)';
       s = spparms;
       spparms('autommd', 0);
       tic
          x = A\b; %#ok Result not used -- strictly for timing.
       times(k, 4) = toc;
       spparms(s);
       clear A b
    end  % End of loop on k.
end % End of pctdemo_task_bench.

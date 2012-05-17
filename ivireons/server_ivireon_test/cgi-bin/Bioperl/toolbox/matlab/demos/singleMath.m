%% Single Precision Math
% This gives some examples of performing arithmetic and linear algebra with
% single precision data.  It also shows an example where the results are
% computed appropriately in single or double precision depending on the input.

% Copyright 1984-2010 The MathWorks, Inc. 
% $Revision: 1.1.4.6 $  $Date: 2010/05/13 17:38:36 $


%% Create Double Precision Data
% Let's first create some data, which is double precision by default.
Ad = [1 2 0; 2 5 -1; 4 10 -1]

%% Convert to Single Precision
% We can convert data to single precision with the |single| function.
A = single(Ad); % or A = cast(Ad,'single');

%% Create Single Precision Zeros and Ones
% We can also create single precision zeros and ones with their respective
% functions.
n=1000;
Z=zeros(n,1,'single');  
O=ones(n,1,'single');

%%
% Let's look at the variables in the workspace.
whos A Ad O Z n

%%
% We can see that some of the variables are of type |single| and that the
% variable |A| (the single precision version of |Ad|) takes half the number
% of bytes of memory to store because singles require just four bytes
% (32-bits), whereas doubles require 8 bytes (64-bits).

%% Arithmetic and Linear Algebra
% We can perform standard arithmetic and linear algebra on singles.

%%
B = A'    % Matrix Transpose

%%
whos B

%%
% We see the result of this operation, |B|, is a single.

%%
C = A * B % Matrix multiplication

%%
C = A .* B % Elementwise arithmetic

%%
X = inv(A) % Matrix inverse

%%
I = inv(A) * A % Confirm result is identity matrix

%%
I = A \ A  % Better way to do matrix division than inv

%%
E = eig(A) % Eigenvalues

%% 
F = fft(A(:,1)) % FFT

%%
S = svd(A) % Singular value decomposition

%%
P = round(poly(A)) % The characteristic polynomial of a matrix

%%
R = roots(P) % Roots of a polynomial

%%
Q = conv(P,P) % Convolve two vectors
R = conv(P,Q)

%%
stem(R); % Plot the result

%% A Program that Works for Either Single or Double Precision
% Now let's look at a function to compute enough terms in the
% Fibonacci sequence so the ratio is less than the correct machine
% epsilon (|eps|) for datatype single or double.

% How many terms needed to get single precision results?
fibodemo('single')

% How many terms needed to get double precision results?
fibodemo('double')

% Now let's look at the working code.
type fibodemo

% Notice that we initialize several of our variables, |fcurrent|,
% |fnext|, and |goldenMean|, with values that are dependent on the
% input datatype, and the tolerance |tol| depends on that type as
% well.  Single precision requires that we calculate fewer terms than
% the equivalent double precision calculation.


displayEndOfDemoMessage(mfilename)

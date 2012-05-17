function [Q,R] = cordicqr(A,varargin) %#eml
%CORDICQR   Orthogonal-triangular factorization via CORDIC
%   [Q,R] = CORDICQR(A) produces an upper triangular matrix R of the same
%   dimension as A and an orthogonal matrix Q so that A = Q*R.  The
%   factorization is done via Givens rotations using CORDIC iterations.  The
%   number of CORDIC iterations is automatically chosen as a function of the
%   data type of A.
%
%   [Q,R] = CORDICQR(A,NITER) uses NITER CORDIC iterations.
%
%   [Q,R] = CORDICQR(A,NITER,ONE) specifies which value is equivalent
%   to one.  For example, if you manually scale integers (e.g. without
%   using the fi object), and your binary point is 14, then you can
%   specify ONE=2^14.
%
%   Limitations:
%     A must be a real-valued matrix.
%     To generate C-MEX or C-Code with Embedded MATLAB, NITER must be
%     constant if it is used as an input.
%     If ONE is input, it must be constant also.
%
%   Examples:
%     %% Double
%     m = 5;                   % Size of matrix
%     A = randn(m);
%     [Q,R] = cordicqr(A)
%     err = Q*R - A
%     I = Q*Q'
%     figure(1); surf(err); title('QR - A'); figure(gcf)
%     figure(2); surf(I); title('Q''Q'); figure(gcf)
%
%     %% Fixed Point
%     % To prevent overflow, you need to scale so there is room for growth,
%     % or add bits to the word length.
%     m = 5;                   % Size of matrix
%     X = rand(m)-0.5;
%     A = sfi(X);
%     % The growth factor is 1.6468 times the square-root of the number of rows of
%     % A. The bit growth is the next integer above the base-2 logarithm of the
%     % growth. 
%     bit_growth = ceil(log2(cordic_growth_constant * sqrt(m)))
%     %
%     % Initialize R with the same values as A, and a word length increased by the bit
%     % growth. 
%     R = sfi(A, get(A,'WordLength')+bit_growth, get(A,'FractionLength'))
%     %
%     % Use R as input and overwrite it.
%     [Q,R] = cordicqr(R)
%     err = double(Q)*double(R) - double(A)
%     I = double(Q)*double(Q')
%     figure(1); surf(err); title('QR - A'); figure(gcf)
%     figure(2); surf(I); title('Q''Q'); figure(gcf)
%
%     %% Integer
%     % Manually scale the inputs and specify what value is equivalent to
%     % one.
%     m = 5;                   % Size of matrix
%     one = 2^30;               % Value equivalent to one
%     A = int32((rand(m)-0.5) * one);
%     [Q,R] = cordicqr(A,31,one)
%     err = (double(Q)*double(R)/one - double(A))/one
%     I = double(Q)*double(Q')/one/one
%     figure(1); surf(err); title('QR - A'); figure(gcf)
%     figure(2); surf(I); title('Q''Q'); figure(gcf)
%
%   See also QR, CORDICQR_DEMO.

%   Copyright 2004-2010 The MathWorks, Inc.
  if nargin>=2 && ~isempty(varargin{1})
     niter = varargin{1};
  elseif isa(A,'double') || isfi(A) && isdouble(A)
    niter = 52;
  elseif isa(A,'single') || isfi(A) && issingle(A)
    niter = single(23);
  elseif isfi(A)
    niter = int32(get(A,'WordLength') - 1);
  elseif isa(A,'int8')
    niter = int8(7);
  elseif isa(A,'int16')
    niter = int16(15);
  elseif isa(A,'int32')
    niter = int32(31);
  elseif isa(A,'int64')
    niter = int32(63);
  else
    assert(0,'First input must be double, single, fi, or signed integer.');
  end
  if nargin>=3 && ~isempty(varargin{2})
    one = varargin{2};
  else
    one = 1;
  end
  % Kn is the inverse of the CORDIC gain, a constant computed outside the loop
  Kn = inverse_cordic_growth_constant(niter);
  % Number of rows and columns in A
  [m,n] = size(A);
  % Compute R in-place over A.
  R = A;
  % Q is initially the identity matrix of the same type as A.  If
  % manual scaling is chosen, then the identity matrix is scaled by
  % the equivalent of 1.
  if isfi(A) && (isfixed(A) || isscaleddouble(A)) && isequal(one,1)
    % If A is a fi object, then we can pick an optimal type for Q.  Since Q
    % is orthonormal, then all elements will be bounded by 1 in magnitude, and
    % it needs one additional bit for the CORDIC growth factor of 1.6468 in
    % intermediate computations.
    Q = fi(one*eye(m), get(A,'NumericType'), 'FractionLength', get(A,'WordLength')-2);
  else
    % Declare Q to be uninitialized m-by-m matrix in the same type as A.  The 
    % repmat will not appear in the generated code.
    Q = eml.nullcopy(repmat(A(:,1),1,m));
    % Initialize Q as the m-by-m identity matrix.
    Q(:) = one*eye(m,class(one));
  end
  % Compute [R Q]
  for j=1:n
    for i=j+1:m
      % Apply Givens rotations, zeroing out the i-jth entry below
      % the diagonal.  Apply the same rotations to the columns of Q
      % that are applied to the rows of R so that Q'*A = R.
      [R(j,j:end),R(i,j:end),Q(:,j),Q(:,i)] = ...
          cordicgivens(R(j,j:end),R(i,j:end),Q(:,j),Q(:,i),niter,Kn);
    end
  end
end

function [x,y,u,v] = cordicgivens(x,y,u,v,niter,Kn)
%CORDICGIVENS  Givens rotation via CORDIC about the first element.
%   [Xn,Yn,Un,Vn] = CORDICGIVENS(X,Y,U,V,NITER) rotates vector (X,Y) about X(1), Y(1) to
%   (Xn,Yn) where Yn(1) is approximately 0.  Vectors U and V are rotated
%   through the same angles.
%
%   The CORDICGIVENS function is numerically equivalent to the following
%   Givens rotation, Algorithm 5.1.5, p. 202 & Algorithm 5.1.6, p. 203,
%   Golub & Van Loan, Matrix Computations, 2nd edition.
%       function [x,y,u,v] = givensrotation(x,y,u,v)
%         a = x(1); b = y(1);
%         if b==0
%           c = 1; s = 0;
%         else
%           if abs(b) > abs(a)
%             t = -a/b; s = 1/sqrt(1+t^2); c = s*t;
%           else
%             t = -b/a; c = 1/sqrt(1+t^2); s = c*t;
%           end
%         end
%         x0 = x;          u0 = u;
%         x = c*x0 - s*y;  u = c*u0 - s*v;
%         y = s*x0 + c*y;  v = s*u0 + c*v;
%       end
%
%   The advantage of the CORDICGIVENS function is that it does not compute
%   the square root or divide operation, which are expensive in fixed-point.
%   Only bit-shifts, addition, and subtraction are needed in the main
%   loop.  And then one scalar-times-vector multiply at the end to normalize
%   the CORDIC gain.
  if x(1)<0
    % Compensation for 3rd and 4th quadrants
    x(:) = -x;  u(:) = -u;
    y(:) = -y;  v(:) = -v;
  end
  for i=0:niter-1
    x0 = x;
    u0 = u;
    if y(1)<0
      % Counter-clockwise rotation
      % x and y form R,         u and v form Q
      x(:) = x - bitsra(y, i);  u(:) = u - bitsra(v, i);
      y(:) = y + bitsra(x0,i);  v(:) = v + bitsra(u0,i);
    else
      % Clockwise rotation
      % x and y form R,         u and v form Q
      x(:) = x + bitsra(y, i);  u(:) = u + bitsra(v, i);
      y(:) = y - bitsra(x0,i);  v(:) = v - bitsra(u0,i);
    end
  end
  % Set y(1) to exactly zero so R will be upper triangular without round off
  % showing up in the lower triangle.
  y(1) = 0;
  % Normalize the CORDIC gain
  x(:) = Kn * x;  u(:) = Kn * u;
  y(:) = Kn * y;  v(:) = Kn * v;
end

function Kn = inverse_cordic_growth_constant(niter)
% Kn = INVERSE_CORDIC_GROWTH_CONSTANT(NITER) returns the inverse of the 
% CORDIC growth factor after NITER iterations. Kn quickly converges to around
% 0.60725.  
  Kn = 1/prod(sqrt(1+2.^(-2*(0:double(niter)-1))));
end

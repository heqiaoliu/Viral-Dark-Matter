function [x,flag,relres,iter,resvec] = cgs(A,b,tol,maxit,M1,M2,x0,varargin)
%CGS   Conjugate Gradients Squared Method.
%   X = CGS(A,B) attempts to solve the system of linear equations A*X=B for
%   X. The N-by-N coefficient matrix A must be square and the right hand
%   side column vector B must have length N.
%
%   X = CGS(AFUN,B) accepts a function handle AFUN instead of the matrix A.
%   AFUN(X) accepts a vector input X and returns the matrix-vector product
%   A*X. In all of the following syntaxes, you can replace A by AFUN.
%
%   X = CGS(A,B,TOL) specifies the tolerance of the method. If TOL is []
%   then CGS uses the default, 1e-6.
%
%   X = CGS(A,B,TOL,MAXIT) specifies the maximum number of iterations. If
%   MAXIT is [] then CGS uses the default, min(N,20).
%
%   X = CGS(A,B,TOL,MAXIT,M) and X = CGS(A,B,TOL,MAXIT,M1,M2) use the
%   preconditioner M or M=M1*M2 and effectively solve the system
%   A*inv(M)*X = B for X. If M is [] then a preconditioner is not
%   applied.  M may be a function handle returning M\X.
%
%   X = CGS(A,B,TOL,MAXIT,M1,M2,X0) specifies the initial guess. If X0 is
%   [] then CGS uses the default, an all zero vector.
%
%   [X,FLAG] = CGS(A,B,...) also returns a convergence FLAG:
%    0 CGS converged to the desired tolerance TOL within MAXIT iterations.
%    1 CGS iterated MAXIT times but did not converge.
%    2 preconditioner M was ill-conditioned.
%    3 CGS stagnated (two consecutive iterates were the same).
%    4 one of the scalar quantities calculated during CGS became too
%      small or too large to continue computing.
%
%   [X,FLAG,RELRES] = CGS(A,B,...) also returns the relative residual
%   NORM(B-A*X)/NORM(B). If FLAG is 0, then RELRES <= TOL.
%
%   [X,FLAG,RELRES,ITER] = CGS(A,B,...) also returns the iteration number
%   at which X was computed: 0 <= ITER <= MAXIT.
%
%   [X,FLAG,RELRES,ITER,RESVEC] = CGS(A,B,...) also returns a vector of the
%   residual norms at each iteration, including NORM(B-A*X0).
%
%   Example:
%      n = 21; A = gallery('wilk',n);  b = sum(A,2);
%      tol = 1e-12;  maxit = 15; M = diag([10:-1:1 1 1:10]);
%      x = cgs(A,b,tol,maxit,M);
%   Or, use this matrix-vector product function
%      %-----------------------------------------------------------------%
%      function y = afun(x,n)
%      y = [0; x(1:n-1)] + [((n-1)/2:-1:0)'; (1:(n-1)/2)'].*x+[x(2:n); 0];
%      %-----------------------------------------------------------------%
%   and this preconditioner backsolve function
%      %------------------------------------------%
%      function y = mfun(r,n)
%      y = r ./ [((n-1)/2:-1:1)'; 1; (1:(n-1)/2)'];
%      %------------------------------------------%
%   as inputs to CGS:
%      x1 = cgs(@(x)afun(x,n),b,tol,maxit,@(x)mfun(x,n));
%
%   Class support for inputs A,B,M1,M2,X0 and the output of AFUN:
%      float: double
%
%   See also BICG, BICGSTAB, BICGSTABL, GMRES, LSQR, MINRES, PCG, QMR,
%   SYMMLQ, TFQMR, ILU, FUNCTION_HANDLE.

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.17.4.5 $ $Date: 2010/02/25 08:11:42 $

if (nargin < 2)
    error('MATLAB:cgs:NotEnoughInputs', 'Not enough input arguments.');
end

% Determine whether A is a matrix or a function.
[atype,afun,afcnstr] = iterchk(A);
if strcmp(atype,'matrix')
    % Check matrix and right hand side vector inputs have appropriate sizes
    [m,n] = size(A);
    if (m ~= n)
        error('MATLAB:cgs:NonSquareMatrix', 'Matrix must be square.');
    end
    if ~isequal(size(b),[m,1])
        error('MATLAB:cgs:RSHsizeMatchCoeffMatrix', ...
            ['Right hand side must be a column vector of' ...
            ' length %d to match the coefficient matrix.'],m);
    end
else
    m = size(b,1);
    n = m;
    if ~iscolumn(b)
        error('MATLAB:cgs:RSHnotColumn',...
            'Right hand side must be a column vector.');
    end
end

% Assign default values to unspecified parameters
if (nargin < 3) || isempty(tol)
    tol = 1e-6;
end
warned = 0;
if tol < eps
    warning('MATLAB:cgs:tooSmallTolerance', ...
        strcat('Input tol is smaller than eps and may not be achieved',...
        ' by CGS\n','         Try to use a bigger tolerance'));
    warned = 1;
    tol = eps;
elseif tol >= 1
    warning('MATLAB:cgs:tooBigTolerance', ...
        strcat('Input tol is bigger than 1 \n',...
        '         Try to use a smaller tolerance'));
    warned = 1;
    tol = 1-eps;
end
if (nargin < 4) || isempty(maxit)
    maxit = min(n,20);
end

% Check for all zero right hand side vector => all zero solution
n2b = norm(b);                     % Norm of rhs vector, b
if (n2b == 0)                      % if    rhs vector is all zeros
    x = zeros(n,1);                % then  solution is all zeros
    flag = 0;                      % a valid solution has been obtained
    relres = 0;                    % the relative residual is actually 0/0
    iter = 0;                      % no iterations need be performed
    resvec = 0;                    % resvec(1) = norm(b-A*x) = norm(0)
    if (nargout < 2)
        itermsg('cgs',tol,maxit,0,flag,iter,NaN);
    end
    return
end

if ((nargin >= 5) && ~isempty(M1))
    existM1 = 1;
    [m1type,m1fun,m1fcnstr] = iterchk(M1);
    if strcmp(m1type,'matrix')
        if ~isequal(size(M1),[m,m])
            error('MATLAB:cgs:WrongPrecondSize', ...
                ['Preconditioner must be a square matrix' ...
                ' of size %d to match the problem size.'],m);
        end
    end
else
    existM1 = 0;
    m1type = 'matrix';
end

if ((nargin >= 6) && ~isempty(M2))
    existM2 = 1;
    [m2type,m2fun,m2fcnstr] = iterchk(M2);
    if strcmp(m2type,'matrix')
        if ~isequal(size(M2),[m,m])
            error('MATLAB:cgs:WrongPrecondSize', ...
                ['Preconditioner must be a square matrix' ...
                ' of size %d to match the problem size.'],m);
        end
    end
else
    existM2 = 0;
    m2type = 'matrix';
end

if ((nargin >= 7) && ~isempty(x0))
    if ~isequal(size(x0),[n,1])
        error('MATLAB:cgs:WrongInitGuessSize', ...
            ['Initial guess must be a column vector of' ...
            ' length %d to match the problem size.'],n);
    else
        x = x0;
    end
else
    x = zeros(n,1);
end

if ((nargin > 7) && strcmp(atype,'matrix') && ...
        strcmp(m1type,'matrix') && strcmp(m2type,'matrix'))
    error('MATLAB:cgs:TooManyInputs', 'Too many input arguments.');
end

% Set up for the method
flag = 1;
xmin = x;                          % Iterate which has minimal residual so far
imin = 0;                          % Iteration at which xmin was computed
tolb = tol * n2b;                  % Relative tolerance
r = b - iterapp('mtimes',afun,atype,afcnstr,x,varargin{:});
normr = norm(r);                   % Norm of residual
normr_act = normr;

if (normr <= tolb)                 % Initial guess is a good enough solution
    flag = 0;
    relres = normr / n2b;
    iter = 0;
    resvec = normr;
    if (nargout < 2)
        itermsg('cgs',tol,maxit,0,flag,iter,relres);
    end
    return
end

rt = r;                            % Shadow residual
resvec = zeros(maxit+1,1);         % Preallocate vector for norms of residuals
resvec(1) = normr;                 % resvec(1) = norm(b-A*x0)
normrmin = normr;                  % Norm of residual from xmin
rho = 1;
stag = 0;                          % stagnation of the method
moresteps = 0;
maxmsteps = min([floor(n/50),5,n-maxit]);
maxstagsteps = 3;

% loop over maxit iterations (unless convergence or failure)

for ii = 1 : maxit
    rho1 = rho;
    rho = rt' * r;
    if (rho == 0) || isinf(rho)
        flag = 4;
        break
    end
    if ii == 1
        u = r;
        p = u;
    else
        beta = rho / rho1;
        if (beta == 0) || isinf(beta)
            flag = 4;
            break
        end
        u = r + beta * q;
        p = u + beta * (q + beta * p);
    end
    if existM1
        ph1 = iterapp('mldivide',m1fun,m1type,m1fcnstr,p,varargin{:});
        if any(~isfinite(ph1))
            flag = 2;
            resvec = resvec(1:2*ii-1);
            break
        end
    else
        ph1 = p;
    end
    if existM2
        ph = iterapp('mldivide',m2fun,m2type,m2fcnstr,ph1,varargin{:});
        if any(~isfinite(ph))
            flag = 2;
            resvec = resvec(1:2*ii-1);
            break
        end
    else
        ph = ph1;
    end
    vh = iterapp('mtimes',afun,atype,afcnstr,ph,varargin{:});
    rtvh = rt' * vh;
    if rtvh == 0
        flag = 4;
        break
    else
        alpha = rho / rtvh;
    end
    if isinf(alpha)
        flag = 4;
        break
    end
    
    q = u - alpha * vh;
    if existM1
        uh1 = iterapp('mldivide',m1fun,m1type,m1fcnstr,u+q,varargin{:});
        if any(~isfinite(uh1))
            flag = 2;
            break
        end
    else
        uh1 = u+q;
    end
    if existM2
        uh = iterapp('mldivide',m2fun,m2type,m2fcnstr,uh1,varargin{:});
        if any(~isfinite(uh))
            flag = 2;
            break
        end
    else
        uh = uh1;
    end
    
    % Check for stagnation of the method
    if abs(alpha)*norm(uh) < eps*norm(x)
        stag = stag + 1;
    else
        stag = 0;
    end
    
    x = x + alpha * uh;            % form the new iterate
    qh = iterapp('mtimes',afun,atype,afcnstr,uh,varargin{:});
    r = r - alpha * qh;
    normr = norm(r);
    normr_act = normr;
    resvec(ii+1) = normr;
    
    % check for convergence
    if (normr <= tolb || stag >= maxstagsteps || moresteps)
        r = b - iterapp('mtimes',afun,atype,afcnstr,x,varargin{:});
        normr_act = norm(r);
        resvec(ii+1,1) = normr_act;
        if (normr_act <= tolb)
            flag = 0;
            iter = ii;
            break
        else
            if stag >= maxstagsteps && moresteps == 0
                stag = 0;
            end
            moresteps = moresteps + 1;
            if moresteps >= maxmsteps
                if ~warned
                    warning('MATLAB:cgs:tooSmallTolerance', ...
                        strcat('Input tol may be smaller than eps*cond(A)',...
                        ' and might not be achieved by CGS\n',...
                        '         Try to use a bigger tolerance'));
                end
                flag = 3;
                iter = ii;
                break;
            end
        end
    end
    
    if normr_act < normrmin        % update minimal norm quantities
        normrmin = normr_act;
        xmin = x;
        imin = ii;
    end
    
    if stag >= maxstagsteps
        flag = 3;
        break
    end
end                                % for ii = 1 : maxit

% returned solution is first with minimal residual
if flag == 0
    relres = normr_act / n2b;
else
    r = b - iterapp('mtimes',afun,atype,afcnstr,xmin,varargin{:});
    if norm(r) <= normr_act
        x = xmin;
        iter = imin;
        relres = norm(r) / n2b;
    else
        iter = ii;
        relres = normr_act / n2b;
    end
end

% truncate the zeros from resvec
if flag <= 1 || flag == 3
    resvec = resvec(1:ii+1);
else
    resvec = resvec(1:ii);
end

% only display a message if the output flag is not used
if nargout < 2
    itermsg('cgs', tol,maxit,ii,flag,iter,relres);
end

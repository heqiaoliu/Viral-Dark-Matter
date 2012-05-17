function [b,fval,exitflag,output] = fzero(FunFcn,x,options,varargin) %#ok<STOUT>
%Embedded MATLAB Library Function

%   Limitations:
%   1. The first argument must be a function handle.  Struct, inline
%   function, and string inputs for the first argument are not supported.
%   2. Up to 3 output arguments are supported. The 4th output argument, a
%   struct, is not supported.
%   3. Only two fields of an option struct are supported: TolX and
%   FunValCheck.  All other options in an option struct input are ignored.
%   The OPTIMSET function is not supported.  Create this structure
%   directly, e.g. opt.TolX = tol; opt.FunValCheck = 'on';
%   The field names must match exactly.  Partial matching is not supported.

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(nargout < 4, ['Too many output arguments.  The Embedded ', ...
    'MATLAB version of FZERO does not support the output struct argument.']);
eml_assert(~isstruct(FunFcn), ...
    'Embedded MATLAB does not support a struct for the first input argument.');
eml_assert(isa(FunFcn,'function_handle'), ...
    'First input must be a function handle.');
eml_assert(nargin >= 2, 'FZERO requires at least two input arguments.');
eml_assert(isa(x,'double'), 'FZERO only accepts inputs of data type double.');
eml_assert(eml_is_const(size(x)), 'Second argument must be fixed-size.');
eml_assert(eml_numel(x) == 1 || eml_numel(x) == 2, ...
    'Second argument must be of length 1 or 2.');
if nargin < 3 || (eml_is_const(isempty(options)) && isempty(options))
    tol = eps;
    funValCheck = false;
else
    eml_assert(isstruct(options), 'Third argument must be an option struct or [].');
    if isfield(options,'TolX') && ...
            eml_is_const(size(options.TolX)) && ~isempty(options.TolX)
        tol = double(options.TolX);
    else
        tol = eps;
    end
    if isfield(options,'FunValCheck')
        funValCheck = strcmp(options.FunValCheck,'on');
    else
        funValCheck = false;
    end
end
% Initialization
exitflag = 1;
% Add a wrapper function to check for Inf/NaN/complex values
% Interval input
if isscalar(x)
    eml_lib_assert(isfinite(x), ...
        'MATLAB:fzero:Arg2NotFinite', ...
        'Second argument must be finite.')
    fx = FunFcn(x,varargin{:});
    eml_assert(isreal(fx), ... 'MATLAB:fzero:checkfun:ComplexFval', ...
        'User function must always return a real value.');
    if fx == 0
        b = x;
        fval = fx;
        return
    elseif ~isfinite(fx)
        eml_error('MATLAB:fzero:ValueAtInitGuessComplexOrNotFinite',...
            'Function value at starting guess must be finite and real.');
    end
    if x ~= 0,
        dx = eml_rdivide(x,50);
    else
        dx = 0.02;
    end
    % Find change of sign.
    twosqrt = sqrt(2);
    a = x; fa = fx; b = x; fb = fx;
    while (fa > 0) == (fb > 0)
        dx = twosqrt*dx;
        a = x - dx;  fa = FunFcn(a,varargin{:});
        if funValCheck
            checkval(fa);
        end
        if ~isfinite(fa)
            exitflag = -3;
            b = eml_guarded_nan; fval = eml_guarded_nan;
            return
        elseif ~isfinite(a)
            exitflag = -6;
            b = eml_guarded_nan; fval = eml_guarded_nan;
            return
        end
        if (fa > 0) ~= (fb > 0) % check for different sign
            break
        end
        b = x + dx;  fb = FunFcn(b,varargin{:});
        if funValCheck
            checkval(fa);
        end
        if ~isfinite(fb)
            exitflag = -3;
            b = eml_guarded_nan; fval = eml_guarded_nan;
            return
        elseif ~isfinite(b)
            exitflag = -6;
            b = eml_guarded_nan; fval = eml_guarded_nan;
            return
        end
    end % while
    savefa = fa; savefb = fb;
else
    eml_lib_assert(isfinite(x(1)) && isfinite(x(2)), ...
        'MATLAB:fzero:Arg2NotFinite', ...
        'Second argument must be finite.')
    a = x(1);
    b = x(2);
    fa = FunFcn(a,varargin{:});
    eml_assert(isreal(fa), ... 'MATLAB:fzero:checkfun:ComplexFval', ...
        'User function must always return a real value.');
    fb = FunFcn(b,varargin{:});
    if ~(isfinite(fa) && isfinite(fb))
        eml_error('MATLAB:fzero:ValuesAtEndPtsComplexOrNotFinite',...
            'Function values at interval endpoints must be finite and real.')
    end
    savefa = fa; savefb = fb;
    if fa == 0
        b = a;
        fval = fa;
        return
    elseif fb == 0
        % b = b;
        fval = fb;
        return
    elseif (fa > 0) == (fb > 0)
        eml_error('MATLAB:fzero:ValuesAtEndPtsSameSign',...
            'The function values at the interval endpoints must differ in sign.')
    end
    % Starting guess scalar input
end % if isscalar(x)
fc = fb;
% The following initializations are required by the compiler.  All will be
% overwritten at the top of the loop.
c = b;
e = 0;
d = 0;
% Main loop, exit from middle of the loop
while fb ~= 0 && a ~= b
    % Ensure that b is the best result so far, a is the previous
    % value of b, and c is on the opposite side of the zero from b.
    if (fb > 0) == (fc > 0) % Always evaluates to true on first iteration.
        c = a;  fc = fa;
        d = b - a;  e = d;
    end
    if abs(fc) < abs(fb)
        a = b;    b = c;    c = a;
        fa = fb;  fb = fc;  fc = fa;
    end
    % Convergence test and possible exit
    m = 0.5*(c - b);
    toler = 2.0*tol*max(abs(b),1.0);
    if (abs(m) <= toler) || (fb == 0.0)
        break
    end
    % Choose bisection or interpolation
    if (abs(e) < toler) || (abs(fa) <= abs(fb))
        % Bisection
        d = m;  e = m;
    else
        % Interpolation
        s = eml_rdivide(fb,fa);
        if (a == c)
            % Linear interpolation
            p = 2.0*m*s;
            q = 1.0 - s;
        else
            % Inverse quadratic interpolation
            q = eml_rdivide(fa,fc);
            r = eml_rdivide(fb,fc);
            p = s*(2.0*m*q*(q - r) - (b - a)*(r - 1.0));
            q = (q - 1.0)*(r - 1.0)*(s - 1.0);
        end;
        if p > 0, q = -q; else p = -p; end;
        % Is interpolated point acceptable
        if (2.0*p < 3.0*m*q - abs(toler*q)) && (p < abs(0.5*e*q))
            e = d;  d = eml_rdivide(p,q);
        else
            d = m;  e = m;
        end;
    end % Interpolation
    % Next point
    a = b;
    fa = fb;
    if abs(d) > toler, b = b + d;
    elseif b > c, b = b - toler;
    else b = b + toler;
    end
    fb = FunFcn(b,varargin{:});
    if funValCheck
        checkval(fb);
    end
end % Main loop
fval = fb; % b is the best value
if abs(fval) <= max(abs(savefa),abs(savefb))
else
    exitflag = -5;
end

%------------------------------------------------------------------

function checkval(x)
% Note: we do not check for Inf as FZERO handles it naturally.  ???
if isnan(x)
    eml_error('MATLAB:fzero:checkfun:NaNFval', ...
        'User function returned NaN when evaluated at %g;\n FZERO cannot continue.',x);
end

%--------------------------------------------------------------------------

function [g,c,d] = gcd(a,b)
%Embedded MATLAB Library Function

%   Copyright 2006-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin == 2, 'Not enough input arguments.');

% Allocate output arrays.
g = eml_scalexp_alloc(eml_scalar_eg(a,b),a,b); 
c = eml.nullcopy(g); 
d = eml.nullcopy(g);

% Check input arguments.
if checkInputs(a,b)
    for k = 1:eml_numel(g)
        g(k) = eml_guarded_nan;
        c(k) = eml_guarded_nan;
        d(k) = eml_guarded_nan;
    end
    return
end

u = eml_expand(eml_scalar_eg(g),[1,3]); 
v = eml.nullcopy(u); % Establish temporary array types.
for k = 1:eml_numel(g)
    ak = eml_scalexp_subsref(a,k);
    bk = eml_scalexp_subsref(b,k);
    u(1) = 1;
    u(2) = 0;
    u(3) = abs(ak);
    v(1) = 0;
    v(2) = 1;
    v(3) = abs(bk);
    while v(3) ~= 0
        q = floor(eml_rdivide(u(3),v(3)));
        t = u - v*q;
        u = v;
        v = t;
    end
    c(k) = u(1)*sign(ak);
    d(k) = u(2)*sign(bk);
    g(k) = u(3);
end

%--------------------------------------------------------------------------

function p = isNonIntGCDArg(x)
% Returns TRUE iff X contains any non-integer elements.
% Equivalent to any(~isfinite(x(:)) | x(:) ~= floor(x(:))) but with no
% chance of creating unnecessary temporary arrays.
p = false;
for k = 1:eml_numel(x)
    xk = x(k);
    flxk = floor(xk);
    if ~isfinite(flxk) || xk ~= floor(xk)
        p = true;
        return
    end
end

%--------------------------------------------------------------------------

function p = hasLargeElements(x,thresh)
% Returns TRUE iff X contains an element larger in magnitude than THRESH.
% Equivalent to any(abs(x(:)) > thresh) but with no chance of creating
% unnecessary temporary arrays.
p = false;
for k = 1:eml_numel(x)
    if abs(x(k)) > thresh
        p = true;
        return
    end
end

%--------------------------------------------------------------------------

function errorflag = checkInputs(a,b)
% Checks input arguments and issues a warning about large inputs if needed.
% Returns false if the arguments are ok, true otherwise.
eml_assert(isa(a,'float'), ['Function ''gcd'' is not defined for values of class ''' class(a) '''.']);
eml_assert(isa(b,'float'), ['Function ''gcd'' is not defined for values of class ''' class(b) '''.']);
eml_assert(isreal(a) && isreal(b), 'Inputs must be real integers.');
errorflag = isNonIntGCDArg(a) || isNonIntGCDArg(b);
if errorflag
    eml_error('MATLAB:gcd:NonIntInputs', 'Inputs must be real integers.');
end
if isa(a,'single') || isa(b,'single')
    largestFlint = eml_const(single(2^24 -1));
else
    largestFlint = eml_const(2^53 - 1);
end
if hasLargeElements(a,largestFlint) || hasLargeElements(b,largestFlint)
    eml_warning('MATLAB:gcd:largestFlint', '%s\n%s', ...
        'Inputs contain values larger than the largest consecutive flint.', ...
        '         Result may be inaccurate.');
end

%--------------------------------------------------------------------------

function y = convergent(x)
%CONVERGENT Embedded MATLAB function for rounding towards nearest integer 
%
%   CONVERGENT(A) returns the result of rounding A towards nearest integer -
%   ties round to nearest even integer.

% Copyright 2007 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.2 $  $Date: 2008/02/20 01:05:02 $

eml_allow_mx_inputs; 

if eml_ambiguous_types
    y = eml_not_const(zeros(size(x)));
    return;
end

eml_assert(nargin == 1, 'Incorrect number of inputs.');

eml_assert(isa(x,'numeric'), [...
        'Function ''convergent'' is not defined for values of class ''' ...
                class(x) '''.']);
            
y = x;

if isempty(x) || isinteger(x)
elseif isreal(x)
    for k = 1:eml_numel(x)
        y(k) = scalar_convergent(x(k));
    end
else
    for k = 1:eml_numel(x)
        y(k) = complex(scalar_convergent(real(x(k))),scalar_convergent(imag(x(k))));
    end
end

function v = scalar_convergent(u)

f = floor(u);

d = u -f;

if d == .5
    if (f/2 - floor(f/2)) == 0
        v = f;
    else
        v = f+1;
    end
else
    v = nearest(u);
end

function y = convergent(a)
%CONVERGENT Fixed-point Embedded MATLAB function for rounding towards nearest integer 
%
%   CONVERGENT(A) returns the result of rounding A towards nearest integer -
%   ties round to nearest even integer.

% Copyright 2007 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.3 $  $Date: 2009/03/30 23:30:00 $

eml_allow_mx_inputs; 

if eml_ambiguous_types
    y = eml_not_const(zeros(size(a)));
    return;
end

eml_assert(nargin==1,'Incorrect number of inputs.');

if isfloat(a)
    [Ty Fy DType] = eml_fi_type_math_and_dtype(a);
    aDType = eml_cast(a,DType);
    yDType = convergent(aDType);
    y = eml_fimathislocal(eml_cast(yDType,Ty,Fy),eml_fimathislocal(a));
else
    y = eml_fi_convergent_helper(a);
end

function y = nearest(x)
%Embedded MATLAB Library Function

% Copyright 2007 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.2 $  $Date: 2008/02/20 01:05:07 $

eml_allow_mx_inputs; 

if eml_ambiguous_types
    y = eml_not_const(zeros(size(x)));
    return;
end

eml_assert(nargin == 1, 'Incorrect number of inputs.');

eml_assert(isa(x,'numeric'), [...
        'Function ''nearest'' is not defined for values of class ''' ...
                class(x) '''.']);
            
if isempty(x) || isinteger(x)
    y = x;
elseif isreal(x)
    y = floor(x+.5);
else
    y = floor(x+(.5+.5i));
end



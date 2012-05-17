function [rangexfi1,rangexfi2] = range(xfi)
% Embedded MATLAB Library function for @fi/range.
%
% RANGE(A) will return true if A is signed, fase  if unsigned.

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/range.m $
% Copyright 2002-2009 The MathWorks, Inc.
%#eml
% $Revision $  $Date: 2009/07/27 20:09:51 $

 
eml_allow_mx_inputs;
if eml_ambiguous_types
    if nargout == 1
        rangexfi1 = [eml_scalar_eg(real(xfi)),eml_scalar_eg(real(xfi))];
        rangexfi2 = [];
    elseif nargout == 2
        rangexfi1 = eml_scalar_eg(real(xfi));
        rangexfi2 = eml_scalar_eg(real(xfi));
    end
    return;
end

%Tx = eml_typeof(xfi);
%Fx = eml_fimath(xfi);
if nargout == 1
    lb=lowerbound(xfi);
    ub=upperbound(xfi);
    rangexfi1 = [eml_scalar_eg(real(xfi)),eml_scalar_eg(real(xfi))];
    rangexfi1(1) = lb;
    rangexfi1(2) = ub;
    rangexfi2 = [];
elseif nargout == 2
    rangexfi1 = lowerbound(xfi);
    rangexfi2 = upperbound(xfi);
end


%---------------------------------------------------------------

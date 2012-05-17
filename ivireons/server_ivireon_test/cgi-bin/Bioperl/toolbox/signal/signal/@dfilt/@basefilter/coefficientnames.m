function c = coefficientnames(Hb)
%COEFFICIENTNAMES  Coefficient names.
%   COEFFICIENTNAMES(Hb) returns a cell array of the names of the
%   coefficients for this filter structure.
%
%   See also DFILT.   
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2005/12/22 18:56:55 $
 
Hd = dispatch(Hb);
c = coefficientnames(Hd(1));
N = length(Hd);
if N>1,
    c = {c};
    for i=2:N,
        c{i} = coefficientnames(Hd(i));
    end
end
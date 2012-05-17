function c = coefficientnames(Hd)
%COEFFICIENTNAMES  Coefficient names.
%   COEFFICIENTNAMES(Hd) returns a vector of cell arrays of the names of the
%   coefficients each section of the discrete-time filter Hd.
%   Example:
%     Hd = dfilt.df2t * dfilt.latticear;
%     c  = coefficientnames(Hd)
%
%   See also DFILT.   
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:07:48 $
  
c = cell(1,length(Hd.Stage));
for k=1:length(Hd.Stage)
  c{k} = coefficientnames(Hd.Stage(k));
end


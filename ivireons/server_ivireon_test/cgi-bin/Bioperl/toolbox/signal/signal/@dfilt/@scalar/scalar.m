function Hd = scalar(g)
%SCALAR Scalar.
%   Hd = DFILT.SCALAR(G) constructs a discrete-time scalar
%   filter object with gain G.
%
%   % EXAMPLE
%   Hd = dfilt.scalar(3)
%
%   See also DFILT/STRUCTURES   
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2005/12/22 18:58:54 $
Hd = dfilt.scalar;

Hd.FilterStructure = 'Scalar';

if nargin>=1
  Hd.Gain = g;
end

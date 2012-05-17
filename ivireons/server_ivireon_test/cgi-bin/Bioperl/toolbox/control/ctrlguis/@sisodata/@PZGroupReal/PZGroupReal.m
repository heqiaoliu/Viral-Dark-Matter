function h = PZGroupReal(Parent)
% Constructor

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:46:38 $

h = sisodata.PZGroupReal;
h.Type = 'Real';

if nargin == 1
   h.Parent = Parent;
end
   
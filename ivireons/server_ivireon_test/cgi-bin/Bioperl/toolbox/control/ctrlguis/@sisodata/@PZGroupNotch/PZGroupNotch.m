function h = PZGroupNotch(Parent)
% Constructor

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:46:31 $

h = sisodata.PZGroupNotch;
h.Type = 'Notch';

if nargin == 1
   h.Parent = Parent;
end
   
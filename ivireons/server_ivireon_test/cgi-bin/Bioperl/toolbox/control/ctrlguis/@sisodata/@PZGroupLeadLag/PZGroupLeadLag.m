function h = PZGroupLeadLag(Parent)
% Constructor

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:46:24 $

h = sisodata.PZGroupLeadLag;
h.Type = 'LeadLag';

if nargin == 1
   h.Parent = Parent;
end
   
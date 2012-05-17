function L = length(NodeList)
%LENGTH of NodeList

%   Author(s): Roshan R Rammohan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:13:34 $

error(nargchk(1,1,nargin,'struct'));

NL = NodeList;
L = length(NL.nodes);

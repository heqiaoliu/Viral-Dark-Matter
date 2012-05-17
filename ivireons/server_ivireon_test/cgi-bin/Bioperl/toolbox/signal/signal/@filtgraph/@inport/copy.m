function IP = copy(ip)
% copy method to force a deep copy.

%   Author(s): Roshan R Rammohan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:13:21 $

error(nargchk(1,1,nargin,'struct'));

IP = feval(str2func(class(ip)));

IP.nodeIndex = ip.nodeIndex;
IP.selfIndex = ip.selfIndex;

if ~isempty(ip.from)
    IP.from = copy(ip.from);
end 

function inp = setfrom(Ip,From)
%inport Constructor for this class.

%   Author(s): Roshan R Rammohan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:13:23 $

error(nargchk(1,2,nargin,'struct'));

if nargin > 0 
    inp=Ip;
end

if nargin > 1
    inp.from = From;
end

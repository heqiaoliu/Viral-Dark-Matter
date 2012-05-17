function disp(obj)
%DISP Display distributed array
%   
%   Example:
%       N = 1000;
%       D = distributed.ones(N);
%       disp(D);
%   
%   See also DISP, DISTRIBUTED, DISTRIBUTED/DISPLAY.
%   


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2009/02/06 14:17:23 $

if numel( obj ) > 0
    thisClassName = 'distributed';
    noName = '';
    dh = dispInternal( obj, thisClassName, noName );
    dh.doDisp();
end

end

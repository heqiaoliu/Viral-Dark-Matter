function display(obj)
%DISPLAY Display distributed array
%   
%   Example:
%       N = 1000;
%       D = distributed.ones(N);
%       display(D);
%   
%   See also DISPLAY, DISTRIBUTED, DISTRIBUTED/DISP.
%   


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2009/02/06 14:17:24 $

objName = inputname( 1 );
thisClassName = 'distributed';

% dispInternal knows how to truncate the object and build the DisplayHelper
% object
dh = dispInternal( obj, thisClassName, objName );
dh.doDisplay();
end

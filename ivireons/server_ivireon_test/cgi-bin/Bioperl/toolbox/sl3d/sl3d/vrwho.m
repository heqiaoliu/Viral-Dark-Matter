function x = vrwho
%VRWHO List all virtual worlds in memory.
%   VRWHO lists all virtual worlds currently present in memory.
%   X = VRWHO returns a vector of handles to all currently present
%   virtual worlds.
%
%   See also VRWHOS, VRWORLD, VRCLEAR.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:09:53 $ $Author: batserve $

% create the world objects
x = vrworld(vrsfunc('VRT3ListScenes'));

% print the info if output argument not required
if nargout==0
fprintf('\n');
disp(x);
clear x;
fprintf('\n');
end

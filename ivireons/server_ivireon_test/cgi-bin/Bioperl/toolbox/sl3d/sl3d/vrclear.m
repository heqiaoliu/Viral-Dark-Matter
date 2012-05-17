function vrclear(p)
%VRCLEAR Purge closed virtual worlds from memory.
%   VRCLEAR deletes all closed virtual worlds from memory.
%   VRCLEAR('-force') deletes all virtual worlds from memory.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:09:25 $ $Author: batserve $

% check switches
forceswitch = nargin>0;
if forceswitch && ~(ischar(p) && strcmpi(p, '-force'));
  error('VR:invalidinarg', 'Invalid input arguments.');
end

% loop over all the worlds
worlds = vrwho;
for i=1:numel(worlds)
  w = worlds(i);  

% if force, close the world first
  while forceswitch && isopen(w)
    close(w);
  end

% delete world if closed
  if ~isopen(w)
    delete(w);
  end
  
end

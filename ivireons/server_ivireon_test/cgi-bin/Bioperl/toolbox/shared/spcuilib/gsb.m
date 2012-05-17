function h = gsb(sys,depth)
%GSB Get Simulink handle to selected blocks in Simulink system
%   GSB(SYS) returns handles to all selected blocks in system
%      SYS and its children.  If omitted, SYS defaults to the
%      current Simulink model (found using GCS).
%   GSB(SYS,DEPTH) constrains the search to the specified integer depth;
%      DEPTH=1 returns only those handles in the current system, and
%      none of its child systems.  If omitted, DEPTH=inf.
%   GSB(0) returns handles to all selected blocks in the root
%      of the current system.
%
%  Example:
%      % Return all selected blocks in
%      % current system and its children:
%      gsb
%
%      % Return selected blocks in current system only:
%      gsb(gcs,1) 
%
%  See also GCS, GCB, GSL.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.10.3 $ $Date: 2009/01/05 17:58:28 $

if nargin<1, sys=slmgr.getCurrentSystem; end
if nargin<2, depth=inf; end
wstate=warning; warning('off'); %#ok
try
    % Could fail if no simulink models/libraries loaded
    h = find_system(sys, ...
        'searchdepth',   depth, ...
        'followlinks',   'on', ...
        'lookundermasks','on', ...
        'type',          'block', ...
        'selected',      'on');
    
    % Remove sys itself from the search results
    % We only want to return what's "under" sys,
    % one level or more (depending on depth), but
    % not sys itself.
    h = setdiff(h,sys);
    
catch e %#ok
    h = [];  % no systems loaded
end
warning(wstate);

% [EOF]

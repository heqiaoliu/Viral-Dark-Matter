function h = gsl(sys,depth)
%GSL Get Simulink handle to selected lines in Simulink system
%   GSL(SYS) returns handles to all selected lines in system
%      SYS and its children.  If omitted, SYS defaults to the
%      current Simulink model (found using GCS).
%   GSL(SYS,DEPTH) constrains the search to the specified integer depth;
%      DEPTH=1 returns only those handles in the current system, and
%      none of its child systems.
%   GSL(0) returns handles to all selected lines in the root
%      of the current system.
%
%  Example:
%      % Return all selected lines in
%      % current system and its children:
%      gsl
%
%      % Return selected lines in current system only:
%      gsl(gcs,1) 
%
%  See also GCS, GCB, GSB.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.10.3 $ $Date: 2009/01/05 17:58:29 $

if nargin<1, sys=slmgr.getCurrentSystem; end
if nargin<2, depth=inf; end
wstate=warning; warning('off'); %#ok
try
    % Could fail if no simulink models/libraries loaded
    h = find_system(sys, ...
        'searchdepth',   depth, ...
        'followlinks',   'on', ...
        'findall',       'on', ...
        'lookundermasks','on', ...
        'type',          'line', ...
        'selected',      'on');

    % No need to remove "sys" itself from the search results
    % (like we did in gsb).  Here, sys is a block or system,
    % whereas the search is only over lines.  No confusion.
    
catch e %#ok
    h = [];  % no systems loaded
end
warning(wstate);

% [EOF]

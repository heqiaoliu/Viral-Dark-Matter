function list = getblklist4src(h,run,src)
% GETBLKLIST4SRC gets the list of blocks that have the same actual src.

%   Author(s): V.Srinivasan
%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/04/05 22:16:33 $

if(~isequal(3, nargin) || ~isnumeric(run)  || isempty(run) || isempty(src) )
  error('fixedpoint:fxptds:dataset:getblklist4src:inValidInputArgs', ...
        'Invalid or not enough input arguments.\nPlease specify RUN (double), SRC (blk object).');
end

if ~isa(src, 'DAStudio.Object')
    list = [];
    return;
end

if  h.isSDIEnabled
    runID = h.getRunID(run);
    runDataMaps = h.RunDataMap.getDataByKey(runID);
    % jlist is a java hash map.
    blklist4srcJHashMap = runDataMaps.getDataByKey('blklist4src');
else
    blklist4srcJHashMap = h.simruns.get(run).get('blklist4src');
end
 
jlist = blklist4srcJHashMap.get(src);

% initialize the list array for improved performance. Initialize them with
% fxptui.simresult as they are most common.
if ~isempty(jlist)
    list(1:numel(jlist)) = fxptui.simresult;
else
    list = [];
    return;
end
cntr = 1;
for idx = 1:numel(jlist)
    hjlist = handle(jlist(idx));
    % This is to protect against entried in the list that are hidden
    % blocks. They are not removed when the model compilation is terminated.
    % The result is removed from the dataset mysteriously, but not from the
    % lists.
    if ~isempty(hjlist) && isa(hjlist.daobject,'DAStudio.Object')
        list(cntr) = hjlist;
        cntr = cntr+1;
    end
end

%Delete excess memory locations.
list(cntr:end) = [];

% [EOF]

function [ok, badname, src] = utctrlCheckLogNames(Model, LoggingNames, MaskTypeToExclude) 
% This function is undocumented and will change in a future release.

% UTCTRLCHECKLOGNAMES 
% Helper function to check that the provided list of logging names does not
% conflict with other logging names used in the model.
%
% [ok, badname, src] = utctrlCheckLogNames(mdl, LoggingNames, MaskTypeToExclude)
%
% Function checks for name conflicts:
%   - within LoggingNames argument
%   - LoggingNames against all scope, to-workspace, data store memory blocks
%   - LoggingNames against all blocks with MaskType in {'Checks_', 'IDDATA SINK'}
%   - LoggingNames against model logging properties
%
% Inputs:
%   mdl          - simulink model to check against
%   LoggingNames - nx2 cell array, 1st column is the block handle that
%                  uses the variable, the second column is the variable name
%   MaskTypeToExclude - cell array with mask types to exclude
%
% Outputs:
%    ok      - true if no logging name conflicts were found, false
%              otherwise
%    badname - logging name that is used in multiple locations
%    src     - cell array of locations that use badname
%

% Author(s): A. Stothert 04-Mar-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/03/26 17:49:21 $

if nargin < 3,
   MaskTypeToExclude = {};
end
if ~iscell(MaskTypeToExclude), 
   MaskTypeToExclude = {MaskTypeToExclude};
end

% Set default return arguments
ok      = true;
badname = '';
src     = {''};

% Remove logging names that correspond to removed blocks
if ~isempty(LoggingNames)
   DelInd = cellfun(@(x)~ishandle(x) || isempty(get(x,'Path')),LoggingNames(:,1));
   LoggingNames(DelInd,:) = [];
end

% Check that no blocks share the same logging variable name
ct = 1;
while ct < size(LoggingNames,1) && ok
   idx = strcmp(LoggingNames( (ct+1):end, 2), LoggingNames{ct,2});
   if any(idx)
      ok = false;
      badname = LoggingNames{ct,2};
      src = {getFullName(LoggingNames{ct,1}); getFullName(LoggingNames{idx(1)+1,1})};
   else
      ct = ct + 1;
   end
end

if ok
   %Check that the logging names don't conflict with other logging names
   %used by blocks, only check names that are used.
   %
   %blkstocheck is a 'database' where the first 2 columns are used by by
   %find_system to identify the blocks, the 3rd column is the block property  
   %indicating that logging is enabled, the 4th column is the block
   %property with the logging variable name. 
   blkstocheck = {...
      'BlockType', 'Scope',           'SaveToWorkspace', 'SaveName';...
      'BlockType', 'ToWorkspace',     [],                'VariableName'; ...
      'BlockType', 'DataStoreMemory', 'DataLogging',     'DataLoggingName'; ...
      'MaskType',  'Checks_',         'SaveToWorkspace', 'SaveName'; ...
      'MaskType',  'IDDATA Sink',     [],                'SaveName'};
   
   if ~isempty(MaskTypeToExclude)
      idx = strcmp(blkstocheck(:,1),'MaskType');
      for ct = 1:numel(MaskTypeToExclude)
         idx = idx & strcmp(blkstocheck(:,2),MaskTypeToExclude{ct});
      end
      blkstocheck = blkstocheck(~idx,:);
   end
   
   ctCheckBlks = 1;
   while ctCheckBlks <= size(blkstocheck,1) && ok
      blks = find_system(Model,'LookUnderMasks','on','RegExp','on',...
         blkstocheck{ctCheckBlks,1},blkstocheck{ctCheckBlks,2});
      ct = 1;
      while ct <= numel(blks) && ok
         if ~isempty(blkstocheck{ctCheckBlks,3}) && ...
               strcmp(get_param(blks{ct},blkstocheck{ctCheckBlks,3}),'on')
            idx = strcmp(get_param(blks{ct},blkstocheck{ctCheckBlks,4}),LoggingNames(:,2));
            if any(idx)
               ok = false;
               badname = get_param(blks{ct},blkstocheck{ctCheckBlks,4});
               src = {blks{ct}; getFullName(LoggingNames{idx,1})};
            end
         else
            idx = strcmp(get_param(blks{ct},blkstocheck{ctCheckBlks,4}),LoggingNames(:,2));
            if any(idx)
               ok = false;
               badname = get_param(blks{ct},blkstocheck{ctCheckBlks,4});
               src = {blks{ct}; getFullName(LoggingNames{idx,1})};
            end
         end
         ct = ct + 1;
      end
      ctCheckBlks = ctCheckBlks + 1;
   end
end

if ok
   %Check the logging names don't conflict with model level logging names
   cfg = getActiveConfigSet(get_param(Model,'Object'));
   paramstocheck = {...
      'SaveTime', 'TimeSaveName'; ...
      'SaveState', 'StateSaveName'; ...
      'SaveOutput', 'OutputSaveName'; ...
      'SaveFinalState', 'FinalStateName'; ...
      'SignalLogging', 'SignalLoggingName'; ...
      'DSMLogging', 'DSMLoggingName'; ...
      'ReturnWorkspaceOutputs', 'ReturnWorkspaceOutputsName'};
   ct = 1;
   while ok &&  ct <= size(paramstocheck,1)
      if strcmp(getProp(cfg,paramstocheck{ct,1}),'on');
         idx = strcmp(LoggingNames(:,2),getProp(cfg,paramstocheck{ct,2}));
         if any(idx)
            ok = false;
            badname = LoggingNames{idx,2};
            src = {sprintf('model property %s',paramstocheck{ct,2}); getFullName(LoggingNames{idx,1})}; 
         end
      end
      ct = ct + 1;
   end
end
end

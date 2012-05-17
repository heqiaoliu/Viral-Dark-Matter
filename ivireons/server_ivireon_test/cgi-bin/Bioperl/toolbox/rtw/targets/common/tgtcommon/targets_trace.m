function varargout = targets_trace(action, varargin)
% TARGETS_TRACE - traces the generated code for a given block in the model
% and also traces the block for a given line text containing the rtw tag.
%
% - traceInfo = targets_trace('model2code', blockFullPath)
% Returns the traceInfo structure for a block in the model that was built
% with the traceability feature enabled. The traceInfo structure contains
% the source file and the rtw tag for that block
%
% - sysFullPath = targets_trace('code2model', lineTextContainingRTWtag)
% Parses the lineTextContainingRTWtag for the RTW Tag and hilites the
% block in the model that matches that RTW Tag. The block hilited is
% returned. 

% Copyright 2006-2010 The MathWorks, Inc.

switch (action)
    case 'model2code'
        blockFullPath = varargin{1};
                
        % validate model for traceability and return relevant info in 
        % traceInfo structure
        traceInfo = i_getBlkTraceInfo(blockFullPath);
        varargout(1) = {traceInfo};
               
    case 'code2model'
        lineTextContainingRTWtag = varargin{1};

        % Find the system that matches this rtw tag
        [sysFullPath, rtwtag] = i_findSystemForRTWTag(lineTextContainingRTWtag);
        
        if isempty(sysFullPath)
          TargetCommon.ProductInfo.error('common', 'TraceabilityInvalidTag', rtwtag);
        else
            % use the find color scheme to avoid confusion that an error 
            % has occurred with the default color scheme
            hilite_system(sysFullPath, 'find');
        end
        varargout(1) = {sysFullPath};
        
  otherwise
    TargetCommon.ProductInfo.error('common', 'UnsupportedAction', action);
end

% process error msgs and return relevant info in traceInfo structure
%__________________________________________________________________________
function traceInfo = i_getBlkTraceInfo(blockFullPath)

traceInfo = [];
model = strtok(blockFullPath, '/');

% Make sure the model has the right options for traceability
i_validateModelForTraceability(model);

% get trace info for the block
try
    h = RTW.TraceInfo(model);
    h.setBuildDir('');
    blk_trace = h.getRegistry(blockFullPath);    
catch Mexp
  % This can happen if the model is not built or if MATLAB is restarted
  % as the traceability information is only retained for the given MATLAB
  % session.
  [id, errstr] = TargetCommon.ProductInfo.message('common', 'TraceabilityNoInfoForBlock', strrep(blockFullPath, sprintf('\n'), ' '));
  errordlg(errstr, 'No Traceability Information');
  TargetCommon.ProductInfo.error('common', 'TraceabilityNoInfoForBlock', strrep(blockFullPath, sprintf('\n'), ' '));
end

blk_rtwname = blk_trace.rtwname;
srcFile = [];
for k = 1:length(blk_trace.location)
    [pathstr, name, ext] = fileparts(blk_trace.location(k).file);
    % If the generated hyperlink is in the model.h file only, then this is
    % probably a virtual subsystem or the block has been optimized away by RTW,
    % and therfore there will be no link for it in the model.c file!
    if strcmpi(ext, '.c')
        srcFile = blk_trace.location(k).file;
        break;
    end
end

if isempty(srcFile)
  [id, err_str] = TargetCommon.ProductInfo.message('common', 'TraceabilityNoTagForBlock', strrep(blockFullPath, sprintf('\n'), ' '));
  errordlg(err_str, 'RTW Tag Does Not Exist');
  TargetCommon.ProductInfo.error('common', 'TraceabilityNoTagForBlock', strrep(blockFullPath, sprintf('\n'), ' '));
end

if ~exist(srcFile, 'file')
  [id, errstr] = TargetCommon.ProductInfo.message('common', 'TraceabilityGeneratedFileMissing', srcFile);
  errordlg(errstr, 'Source File Not Found');
  TargetCommon.ProductInfo.error('common', 'TraceabilityGeneratedFileMissing', srcFile);
end

blk_rtwname_flat = strrep(blk_rtwname, sprintf('\n'), ' ');

% return struct with relevant info
traceInfo.blk_rtwname_flat = blk_rtwname_flat;
traceInfo.srcFile = srcFile;
traceInfo.blockFullPath = blockFullPath;

% process error msgs and find the system that matches this rtw tag
%__________________________________________________________________________
function [pathname,rtwtag] = i_findSystemForRTWTag(lineTextContainingRTWtag)

% Make sure the model has the right options for traceability
%i_validateModelForTraceability(model);

% Find the rtw c tag: find text enclosed between '< and '
rtwtag = []; %#ok<NASGU>
rtwtag = regexp(lineTextContainingRTWtag, '''<(.*?)''', 'tokens', 'once');
if isempty(rtwtag)
  TargetCommon.ProductInfo.error('common', 'TraceabilityNoTagOnLine', lineTextContainingRTWtag);
end

% add the chopped '<'
rtwtag = ['<' rtwtag{1}];

% get trace info for the last built model
try
    traceInfo = rtwprivate('rtwctags_registry', 'get');
catch
  TargetCommon.ProductInfo.error('common', 'TraceabilityNoInfo');
end


pathname = [];
for i=1:length(traceInfo)
    % strip new lines as rtwtags in generated code do not have new lines
    rtwname_flat = strrep(traceInfo(i).rtwname, sprintf('\n'), ' ');
    if strcmp(rtwname_flat, rtwtag)
        pathname = traceInfo(i).pathname;
        break;
    end
end


%__________________________________________________________________________
function i_validateModelForTraceability(model)
% make sure the model is properly setup for traceability

cs = getActiveConfigSet(model);

% assume that model is setup properly
ok2trace = true;

% get required params
trace_params = targets_get_trace_parameters();

% also make sure the model is an ERT based Target
trace_params{end+1} = 'IsERTTarget';

% loop over params and see whether one of them is off
for k = 1:length(trace_params)
    trace_param = trace_params{k};
    if strcmpi(get_param(cs, trace_param), 'off')
        ok2trace = false;
        break;
    end
end

% issue error msg
if ~ok2trace
  TargetCommon.ProductInfo.error('common', 'TraceabilityModelConfiguration', trace_param);
end

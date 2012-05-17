function varargout = iload(fName)
%ILOAD    Load an instrumentation set.

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/06/11 16:05:25 $

% Default iset extension:
[p, n, e]=fileparts(fName);
if isempty(e)
    fName = [fName '.iset'];
end

% Load the message log class into memory to avoid extmgr.Property issues.
% We need to figure out a better way to do this in the future.  MCOS should
% take care of this by having enum types exist outside of classes.
findclass(findpackage('uiservices'), 'MessageLog');

% Load iset:
data = load('-mat', fName);

% Quick error-check:
%    must be a scalar struct with the field ".inst"
if ~isstruct(data) || (numel(data)~=1) || ~isfield(data, 'inst')
    DAStudio.error('Spcuilib:scopes:InvalidISet');
elseif isempty(data.inst)
    DAStudio.warning('Spcuilib:scopes:EmptyISet', fName);
    return;
end

% Convert old structures into ScopeCfg objects.
if isstruct(data.inst)

    % Loop over each element in the set and convert it to a ScopeCfg.
    newData.inst = convert2ScopeCfg(data.inst(1).args);
    for indx = 2:length(data.inst)
        newData.inst(indx) = convert2ScopeCfg(data.inst(indx).args);
    end

    data = newData;

    % Issue a warning that we are loading in an old set.
    DAStudio.warning('Spcuilib:scopes:OldISet', fName);
end

% Create new scopes for each element in the instrumentation set.
isetErrors = '';

for indx = 1:length(data.inst)
    try
        h(indx) = uiscopes.new(data.inst(indx), [indx length(data.inst)]); %#ok<AGROW>
    catch e
        
        % Next, concatenate source-line information
        newErr = uiscopes.message('FailedToOpenISetInstance', indx, uiservices.cleanErrorMessage(e));
        if isempty(isetErrors)
            isetErrors = newErr;
        else
            isetErrors = sprintf('%s\n\n%s', isetErrors, newErr);
        end
    end
end

if ~isempty(isetErrors)
    
    % No reason to internationalize here.  The composite message should be
    % internationalized.
    error('Spcuilib:scopes:FailedToOpenInstance', '%s', char(isetErrors));
end

if nargout > 0
    varargout = {h};
end

% -------------------------------------------------------------------------
function hScopeCfg = convert2ScopeCfg(s)
% Convert the old structure to a uiscopes.ScopeCfg object

hScopeCfg = uiscopes.ScopeCfg;

if s.docked
    wStyle = 'docked';
else
    wStyle = 'undocked';
end

hConfigDb = extmgr.ConfigDb;

% Turn everything on.
hConfigDb.add('Sources', 'File', true);
hConfigDb.add('Sources', 'Workspace', true);
hConfigDb.add('Sources', 'Simulink', true);
hConfigDb.add('Visuals', 'Video', true);
hConfigDb.add('Tools', 'Image Navigation Tools', true);
hConfigDb.add('Tools', 'Instrument Sets', true);
hConfigDb.add('Tools', 'Pixel Region Tool', true);
hConfigDb.add('Tools', 'Image Tool', true);

hConfig = hConfigDb.findConfig('Tools', 'Image Navigation Tools');
hConfig.PropertyDb.add('Magnification', 'double', s.zoom);
hConfig.PropertyDb.add('FitToView', 'bool', s.zoomfit);

hScopeCfg.AppName = 'MPlay';
hScopeCfg.ScopeCLI = hScopeCfg.createScopeCLI(s.source);
hScopeCfg.ConfigurationFile = 'mplay.cfg';
hScopeCfg.CurrentConfiguration = hConfigDb;
hScopeCfg.Position = s.position;
hScopeCfg.WindowStyle = wStyle;

% [EOF]

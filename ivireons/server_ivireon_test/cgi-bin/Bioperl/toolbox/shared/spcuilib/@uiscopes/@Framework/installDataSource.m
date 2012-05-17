function installDataSource(this, newSource)
%INSTALLDATASOURCE Install a new datasource and update GUI.
%   Turns on flow of data for streaming sources as last step.
%
%   Note: Assumes player is stopped; exclusively called by newSource.
%   Note: Assumes current DataSource is closed; again, newSource

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2010/03/31 18:44:25 $

% If new datasource supplied, close old
% source and copy in new one.
%
% If no new datasource supplied, assume
% current data source is new
%

if nargin>1
    % Store new datasource
    %  (the most important step!)
    this.DataSource = newSource;
end

this.DataSource.activate;

% If data source came into this fcn with cancel state,
% get out now:
if strcmp(this.DataSource.ErrorStatus,'cancel')
    return
end

% Install playback controls only if new data source passed
%
if nargin>1
    installPlaybackControls(this);
    
    % Disable various tools if video data is empty
    % local_ConfigureForEmptyVideoSource(this);
else
    % Just update existing playback controls
    update(this.DataSource.Controls);
end

% Send event to notify listeners that the datasource has changed.
send(this, 'DataSourceChanged', ...
    handle.EventData(this, 'DataSourceChanged'));

if ~strcmp(this.DataSource.ErrorStatus,'cancel')
    local_DataSourceMsg(this);
end

send(this, 'DataLoadedEvent', ...
    uiservices.EventData(this, 'DataLoadedEvent', isDataLoaded(this.DataSource)));

% Turn on the flow of data for streaming sources:
% (last event might still be percolating through,
%  but it has no impact on the data pipeline)
enableData(this.DataSource);

% -------------------------------------------------------------------------
function local_DataSourceMsg(this)
% Put up message if data source has empty video frames
% defined as having

hSource = this.DataSource;
% Detect all types of empty data matrices:
if isDataEmpty(hSource)
    screenMsg(this, emptyDataMessage(hSource));
else
    
    validateVisual(this);
end

% -------------------------------------------------------------------------
function installPlaybackControls(this)
%INSTALLPLAYBACKCONTROLS Install and update data source-speicfic playback controls
%and readouts, including:
%   - button states, visibility
%   - menu checks, labels, visibility
%   - status bar text
%   - keyboard handler

src = this.DataSource;

install(src.Controls);
enable(src.Controls, 'on');
update(src.Controls);

% [EOF]

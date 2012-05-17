function this = VideoInfo(hScopeApp)
%VideoInfo Constructor for MPlay.VideoInfo
%   Manages updates to open dialog when property values change
%   Installs listener of MPlay GUI to close dialog automatically

% Copyright 2004-2010 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2010/03/31 18:43:08 $

this = scopeextensions.VideoInfo;

% Initialize DialogBase properties
%this.TitlePrefix = 'Video Information';
this.initExt('Video Information', hScopeApp);

% Listen to changes on dataTypeDst
% These must be reflected in the display, but are done
% in ways that do not otherwise trigger updates
% (i.e., by colormap scaling changes)
this.DisplayDataTypeListener = handle.listener(this, this.findprop('DisplayDataType'), ...
    'PropertyPostSet', @(h, ev) onDisplayDataTypeChange(this));
this.DataReleasedListener = handle.listener(hScopeApp, 'DataReleased', ...
    @(h, ev) dataReleased(this));
this.SourceNameChangedListener = handle.listener(hScopeApp, 'SourceNameChanged', ...
    @(h, ev) sourceNameChanged(this));

% -------------------------------------------------------------------------
function onDisplayDataTypeChange(this)

% Only update data if dialog open
hDlg = this.Dialog;
if ~isempty(hDlg)
    update(this);
    refresh(hDlg);
end

% -------------------------------------------------------------------------
function dataReleased(this)

set(this, ...
    'PlaybackInfo', [], ...
    'DisplayDataType', '', ...
    'SourceType', '', ...
    'SourceLocation', '', ...
    'ImageSize', '', ...
    'ColorSpace', '', ...
    'DataType', '');

if isa(this.Dialog, 'DAStudio.Dialog')
    this.Dialog.refresh;
end

% [EOF]

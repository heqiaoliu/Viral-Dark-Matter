function this = VideoVisual(varargin)
%VIDEOVISUAL Construct a VIDEOVISUAL object

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/02/29 13:11:01 $

this = scopeextensions.VideoVisual;

this.initVisual(varargin{:});

% Create the Video Information dialog.
this.VideoInfo = scopeextensions.VideoInfo(this.Application);
update(this.VideoInfo);
connect(this, this.VideoInfo, 'down');

this.DataLoadedListener = handle.listener(this.Application, ...
    'DataLoadedEvent', @(hApp, ev) dataReleased(this, ev));
this.DataSourceChangedListener = handle.listener(this.Application, ...
    'DataSourceChanged', @(hApp, ev) dataSourceChanged(this));

% [EOF]

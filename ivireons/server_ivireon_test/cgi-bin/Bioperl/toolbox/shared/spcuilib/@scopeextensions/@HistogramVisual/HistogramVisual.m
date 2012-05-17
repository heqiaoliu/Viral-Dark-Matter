function this = HistogramVisual(varargin)
% HISTOGRAMVISUAL Construct a HistogramVisual object
    
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $   $Date: 2010/03/31 18:41:24 $
    
this = scopeextensions.HistogramVisual;
this.initVisual(varargin{:});


if ~(this.NTXFeaturedOn)
    % Create the Histogram Information dialog.
    this.HistogramInfo = scopeextensions.HistogramInfo(this.Application);
    update(this.HistogramInfo);
    connect(this, this.HistogramInfo, 'down');
    this.UpdateDialogsTitleBarEvent = handle.listener(this.Application, ...
        'UpdateDialogsTitleBarEvent', @(hSrc, ev) locUpdateLabel(this));
    this.DataLoadedListener = handle.listener(this.Application, ...
        'DataLoadedEvent', @(hApp, ev) dataReleased(this, ev));
end

this.DataObject = scopeextensions.HistogramData;

%------------------------------------------
function locUpdateLabel(this)

%Set the title of the scope.
title(this.Axes,getTitle(this),'Interpreter','none');


%----------------------------------------

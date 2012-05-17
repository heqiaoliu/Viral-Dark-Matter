function wf = addwave(this,src,axespos,updatefcn,varargin)
%ADDWAVE  Adds a new wave to a wave plot.
%

% Copyright 2005-2007 The MathWorks, Inc.

%% Overloaded to circumevent the behavior of the @waveform localize method
%% which will not allow a datasrc to direct all components of a response to
%% the same channel

% Create a new @waveform object
wf = wavepack.waveform;
wf.Parent = this;

% Data source supplied
if ~isa(src, 'wrfc.datasource')
  error('tsplot:addwave:invdataSrc',...
      'Data source should be a subclass of wrfc.datasource.')
end
wf.DataSrc = src;
wf.Name = src.Name;

% Localize RowIndex and ColumnIndex
wf.ColumnIndex = 1;
wf.RowIndex = repmat(axespos,[size(src.Timeseries.Data,2) 1]);

% Initialize new @waveform
initialize(wf,1)

% Add default tip (tip function calls MAKETIP first on data source, then on view)
viewer = tsguis.tsviewer;
if viewer.DataTipsEnabled
    addtip(wf)
elseif ~isempty(wf.View) && ishandle(wf.View) && ~isempty(wf.View.Curves)
    set(wf.View.Curves,'ButtonDownFcn',{@tsLineButtonDown this});
end

% Set style
% RE: Before adding wave to plot's wave list so that legend available to RC
% menus
SList = get(allwaves(this),{'Style'});
StyleList = cat(1,SList{:});
wf.Style = this.StyleManager.dealstyle(StyleList);  % use next available style
wf.datafcn = {updatefcn src wf varargin{:}};
this.Waves = [this.Waves; wf];
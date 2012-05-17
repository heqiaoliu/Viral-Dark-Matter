function retval = surfaceplot(varargin)
%SURFACEPLOT Surface plot constructor

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision $  $Date: 2008/04/11 15:37:12 $

h = localConstructor(varargin{:});

LaddListeners(h);

% Activate datamode listeners only if this object is 
% not being deserialized
if ~isappdata(0,'BusyDeserializing')
   [hListener] = LGetListeners(h);
   set(hListener,'Enabled','on');
end

if nargout>0
  retval = h;
end

% Update plot tool
plotdoneevent(ancestor(h,'axes'),h);

%--------------------------------------------------%
function [h] = localConstructor(varargin)

% Default values
xdata = [];
ydata = [];
zdata = [];
cdata = [];
xdatamode = 'auto';
ydatamode = 'auto';
cdatamode = 'auto';

% Determine number of numeric data arguments
len = length(varargin);
n = 1;
while n <= len && isnumeric(varargin{n}) 
  n = n + 1;
end
n = n - 1;

% Determine appropriate syntax
switch (n)

  % SURFACEPLOT(Z,...)
  case 1
    zdata = varargin{1};
    xdata = 1:size(zdata,2);
    ydata = (1:size(zdata,1))';
    cdata = zdata;

  % SURFACEPLOT(Z,C,...)
 case 2
    cdatamode = 'manual';
    zdata = varargin{1};
    xdata = 1:size(zdata,2);
    ydata = (1:size(zdata,1))';
    cdata = varargin{2};
  
  % SURFACEPLOT(X,Y,Z,...)
 case 3
    xdatamode = 'manual';
    ydatamode = 'manual';
    xdata = varargin{1};
    ydata = varargin{2};
    zdata = varargin{3};
    cdata = zdata;
 
  % SURFACEPLOT(X,Y,Z,C,...)
 case 4
    xdatamode = 'manual';
    ydatamode = 'manual';
    cdatamode = 'manual';
    xdata = varargin{1};
    ydata = varargin{2};
    zdata = varargin{3};
    cdata = varargin{4};    
end

% Cycle through parameter list and pull out properties defined by 
% this class since we can't pass them down to the super constructor 
% (surface).
argin_param = {varargin{(n+1):end}};
len = length(varargin)-n;
propsToSet = {};
if len > 0 
  % must be even number for param-value syntax
  if mod(len,2)>0 
      error('MATLAB:graph3d:surfaceplot','Invalid input arguments');
  end

  c = {varargin{(n+1):end}};  
  idxremove = []; 
  for i = 1:2:length(c)
     switch(c{i})
         case 'xdata' 
            xdatamode = 'manual';
         case 'ydata'
            ydatamode = 'manual';
         case 'cdata'
            cdatamode = 'manual';
      
         % Public properties defined by this class (see schema.m)
         case  {'XDataMode','XDataSource',...
                'YDataMode','YDataSource',...
                'CDataMode','CDataSource',...
                'ZDataSource','DisplayName',...
                'Initialized'}

            idxremove = [i,i+1,idxremove];
            propsToSet = { propsToSet{:},c{i}, c{i+1} };
      end % switch     
  end % for
  
  % set indices of fields to keep
  idxkeep = 1:length(c);
  idxkeep(idxremove) = [];

  argin_param = {c{idxkeep}};
end
                          
argin_data = {};
if n>0
   argin_data = {'xdata',xdata,...
                 'ydata',ydata,...
                 'zdata',zdata,...
                 'cdata',cdata};
end

% call super constructor
argin = {argin_data{:},argin_param{:}};

h = graph3d.surfaceplot(argin{:});

% Set mode values
set(h,'XDataMode',xdatamode);
set(h,'YDataMode',ydatamode);
set(h,'CDataMode',cdatamode);

% Set properties defined by this class
if length(propsToSet)>1
   set(double(h),propsToSet{:});
end

%--------------------------------------------------%
function LaddListeners(h)

hProps = get(h,'InternalPropertyHandles');
hListener = handle.listener(h,hProps,...
                            'PropertyPostSet',@localPropertyPostSet);
set(hListener,'Enabled','off');
LSetListeners(h,hListener);

%--------------------------------------------------------%
function LSetListeners(h,l)
set(h,'InternalListener',l);

%--------------------------------------------------------%
function [l] = LGetListeners(h)
l = get(h,'InternalListener');

%--------------------------------------------------------%
function localPropertyPostSet(obj,evd)

% Delete event based on property name
switch lower(get(obj,'Name'))
   
    case 'xdata'
        LsetXYCData(obj,evd);
    case 'ydata'
        LsetXYCData(obj,evd);
    case 'zdata'
        LsetZData(obj,evd);
    case 'cdata'
        LsetXYCData(obj,evd);
    case 'xdatamode'
        LsetXYCDataMode(obj,evd);
    case 'ydatamode'
        LsetXYCDataMode(obj,evd);
    case 'cdatamode'
        LsetXYCDataMode(obj,evd);
end

%--------------------------------------------------------%
function LsetXDataSilently(h,zdata)

% turn off xdatamode listener before setting xdata
l = LGetListeners(h);
set(l,'enable','off');
set(h,'XData',1:size(zdata,2));
set(l,'enable','on');

%--------------------------------------------------------%
function LsetYDataSilently(h,zdata)

% turn off ydatamode listener before setting xdata
l = LGetListeners(h);
set(l,'enable','off');
set(h,'YData',(1:size(zdata,1))');
set(l,'enable','on');

%--------------------------------------------------------%
function LsetCDataSilently(h,zdata)

% turn off xdatamode listener before setting xdata
l = LGetListeners(h);
set(l,'enable','off');
set(h,'CData',zdata);
set(l,'enable','on');

%--------------------------------------------------------%
function LsetZData(hSrc, eventData)

h = handle(eventData.affectedObject);

% User set ZData property, update XData,YData,CData if in auto-mode
if strcmp(h.xdatamode,'auto') 
    LsetXDataSilently(h,eventData.newvalue);
end
if strcmp(h.ydatamode,'auto') 
    LsetYDataSilently(h,eventData.newvalue);
end
if strcmp(h.cdatamode,'auto') 
    LsetCDataSilently(h,eventData.newvalue);
end

%--------------------------------------------------------%
function LsetXYCData(hSrc, eventData)

h = eventData.affectedObject;

% User is setting {X,Y}Data property, set corresponding 
% DataMode property to be manual
prop = hSrc.name;
set(h,[prop 'Mode'],'manual');

%--------------------------------------------------------%
function LsetXYCDataMode(hSrc, eventData)

h = eventData.affectedObject;
modeprop = hSrc.name;

if strcmp(get(h,modeprop),'auto') 
  switch lower(modeprop)
     case 'xdatamode'
        LsetXDataSilently(h,h.zdata);
     case 'ydatamode'
        LsetYDataSilently(h,h.zdata);
     case 'cdatamode'
        LsetCDataSilently(h,h.zdata);
  end
end
                          
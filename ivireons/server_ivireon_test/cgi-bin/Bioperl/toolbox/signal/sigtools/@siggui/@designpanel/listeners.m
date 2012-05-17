function listeners(this, eventData, fcn, varargin)
%LISTENERS Listeners to the properties of the Design Panel

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.35.6.18 $  $Date: 2009/01/05 18:00:32 $

feval(fcn, this, eventData, varargin{:});

% ------------------------------------------------------------
function responsetype_listener(this, eventData)
%responseTYPE_LISTENER Listener to the responsetype property

hFig = get(this, 'FigureHandle');
p    = getptr(hFig);
setptr(hFig, 'watch');

setup_designmethods(this);
oldDM = get(this, 'CurrentDesignMethod');
buildcurrent(this);
if isequal(this.CurrentDesignMethod, oldDM)
    currentdesignmethod_listener(this);
end

set(this, 'isDesigned', 0);
sendfiledirty(this);

set(hFig, p{:});


% ------------------------------------------------------------
function designmethod_listener(this, eventData)
%DESIGNMETHOD_LISTENER Listener to the design method

hFig = get(this, 'FigureHandle');
p    = getptr(hFig);
setptr(hFig, 'watch');

% Build a new design method object
buildcurrent(this);
set(this, 'isDesigned', 0);
sendfiledirty(this);

set(hFig, p{:});

% ------------------------------------------------------------
function orderrequested_listener(this, eventData)

hSrc = get(eventData, 'Source');

hFO = getcomponent(this, '-class', 'siggui.filterorder');
setorder(hSrc, get(hFO, 'Order'));

% ------------------------------------------------------------
function staticresponse_listener(this, eventdata)
%STATICRESPONSE_LISTENER Listener to the staticresponse property

visState = get(this, 'Visible');

% If the object is visible than we can use the static response
if strcmpi(visState, 'On'),
    visState = get(this, 'StaticResponse');
end

hax = findobj(this.FigureHandle, 'type', 'axes', 'tag', 'staticresponse_axes');

set(hax, 'Visible', visState);
set(allchild(hax), 'Visible', visState);

if strcmpi(visState, 'Off'),
    clrStaticResponse(this);
end

lclStaticResponse(this);

% ------------------------------------------------------------
function usermodifiedspecs_listener(this, eventData)
%USERMODIFIEDSPECS_EVENTCB Callback to the UserModifiedSpecs event 

if isempty(get(this, 'CurrentDesignMethod')),
    
    freqstate = getstate(this.Frames(3));
    magstate  = getstate(this.Frames(4));
    
    hcomp = this.ActiveComponents;
    hcomp(3) = fdadesignpanel.lpfreqpassstop;
    hcomp(4) = fdadesignpanel.lpmag;
    set(hcomp(3), 'Fpass', freqstate.Values{1}, ...
        'Fstop', freqstate.Values{2}, ...
        'Fs', freqstate.Fs, ...
        'freqUnit', freqstate.Units);
    
    set(hcomp(4), 'IRType', 'FIR', 'magUnits', magstate.FIRunits)
    if strcmpi(magstate.FIRunits, 'db')
        set(hcomp(4), 'Apass', magstate.Values{1}, 'Astop', magstate.Values{2});
    end

    render(hcomp(3), this.Frames, this.FigureHandle);
    render(hcomp(4), this.Frames, this.FigureHandle);
    setcomponentstate(this, this.PreviousState, hcomp(3));
    setcomponentstate(this, this.PreviousState, hcomp(4));
    
    set(hcomp(3:4), 'Visible', this.Visible);
    
    this.ActiveComponents = hcomp;
    
    addcomponent(this, hcomp(3:4));
    
    buildcurrent(this);
    
    set(this, 'isDesigned', 0);
    return;
end

hSrc = get(eventData, 'Source');

if isa(hSrc, 'schema.prop'), hSrc = get(eventData, 'AffectedObject'); end

if isa(hSrc, 'siggui.abstractfilterorder') || isa(hSrc, 'siggui.firwinoptionsframe'),
    currentdesignmethod_listener(this, eventData);
else
    staticresponse_listener(this, eventData);
end

set(this, 'isDesigned', 0);
sendfiledirty(this);
if ~this.isLoading
    sendstatus(this, 'Ready');
end

% ------------------------------------------------------------
function currentdesignmethod_listener(this, eventData)
%CURRENTDESIGNMETHOD_LISTENER Listener to the currentdesignmethod property

hFig = get(this, 'FigureHandle');
p    = getptr(hFig);
setptr(hFig, 'watch');

hDM     = get(this, 'CurrentDesignMethod');
if isempty(hDM),
    buildcurrent(this);
    set(hFig, p{:});
    return;
end

if isa(hDM, 'filtdes.fir1'),
    updateForFIR1(this);
end

mode = getmode(this);

if isvisprop(hDM, 'orderMode'),
    set(hDM, 'orderMode', mode);
end

frames  = whichframes(hDM);

[hfound, hnot] = parsecomponents(this, frames);

% Disable the frames that we are not going to use.
disablehnots(hnot);

hfound = synccomps_w_frames(this, hfound, frames);

addlisteners2components(this);

% set(hfound, 'Visible', this.Visible);
set_unused_off(this, hfound);
set(hfound, 'Visible', this.Visible);

set(this, 'ActiveComponents', hfound);

lclStaticResponse(this);

set(hFig, p{:});
if ~this.isLoading
    sendstatus(this, 'Ready');
end

% ------------------------------------------------------------
%   Utility Functions
% ------------------------------------------------------------

% ------------------------------------------------------------
function updateForFIR1(this)

hFW  = getcomponent(this, '-class', 'siggui.firwinoptionsframe');
if ~isempty(hFW),
    
    % Make sure that we only have 1 frame here.  This is probably an undo
    % safety valve.  Might not be necessary.
    hFW = hFW(1);
    
    if ~isminordersupported(hFW),
        setMode(this, 'Specify');
    end

    mode = getmode(this);
    if strcmpi(mode, 'minimum')
        isminord = 1;
    else
        isminord = 0;
    end
    set(hFW, 'isminorder', isminord);

    set(this.CurrentDesignMethod, 'Window', get(hFW, 'Window'));
end

% ------------------------------------------------------------
function lclStaticResponse(this)

hFig = get(this, 'FigureHandle');

if strcmpi(this.Visible, 'on') && strcmpi(this.StaticResponse, 'On'),
    
    hax = findobj(this.FigureHandle, 'type', 'axes', 'tag', 'staticresponse_axes');
    
    h    = get(this, 'Handles');
    hDM  = get(this, 'CurrentDesignMethod');
    
    clrStaticResponse(this);
    oldaxes = get(hFig, 'CurrentAxes');
    
    set(hFig, 'CurrentAxes', hax);
    
    if isempty(hDM),
        staticremezlp(hax);
    else
        [package, method] = strtok(get(this, 'DesignMethod'), '.');
        method(1) = [];
        
        staticres(hax, get(this, 'SubType'), method, getActiveFrames(this));
        set(hFig, 'CurrentAxes', oldaxes);
    end
else
    setzoomstate(hFig);
end

% ------------------------------------------------------------
function clrStaticResponse(this)

h = get(this, 'Handles');
hax = findobj(this.FigureHandle, 'type', 'axes', 'tag', 'staticresponse_axes');
delete(allchild(hax)); %, hax));
set(hax, 'XTick', [], 'YTick', []);

% ------------------------------------------------------------
function setup_designmethods(this, eventData)

filtertype = get(this, 'ResponseType');

if isempty(filtertype), return; end

at = get(this, 'AvailableTypes');

% Get the iir and fir methods for the current filter type

indx = find(strcmp({at.(filtertype).tag}, this.SubType));
if isempty(indx),
    iir = [];
    fir = [];
else
    iir = at.(filtertype)(indx).iir;
    fir = at.(filtertype)(indx).fir;
end

hDM = getcomponent(this, '-class', 'siggui.selector', 'Name', 'Design Method');

% If there are no IIR methods, disable the IIR popup.
if ~isempty(iir),
    
    % If there are IIR methods, make sure that the popup is enabled.
    enableselection(hDM, 'iir');
    
    alltags = get(hDM, 'Identifiers');
    allstrs = get(hDM, 'Strings');
    
    alltags{1} = {'iir' iir.tag};
    allstrs{1} = {'IIR' iir.name};
    
    set(hDM, 'Identifiers', alltags);
    set(hDM, 'Strings', allstrs);
end

% If there are no FIR methods, disable the FIR popup.
if ~isempty(fir),
    
    % If there are FIR methods, make sure that the popup is enabled.
    enableselection(hDM, 'fir');
    
    % Set the FIR popup to match the currently available fir methods
    alltags = get(hDM, 'Identifiers');
    allstrs = get(hDM, 'Strings');
    
    alltags{2} = {'fir' fir.tag};
    allstrs{2} = {'FIR' fir.name};
    
    set(hDM, 'Identifiers', alltags);
    set(hDM, 'Strings', allstrs);
end

if isempty(iir), disableselection(hDM, 'iir'); end
if isempty(fir), disableselection(hDM, 'fir'); end

% ------------------------------------------------------------
function set_unused_off(this, hfound)

% Loop over the activecomponents and get the names of the frames that they require.

for indx = 1:length(hfound),
    if isa(hfound(indx), 'fdadesignpanel.abstractfiltertype'),
        hfound(indx) = allchild(hfound(indx));
    end
end

hframes = get(this, 'Frames');
hframes = setdiff(hframes, hfound);

% Find the frames that are not used and set visible off.
set(hframes, 'Visible','Off');


% ------------------------------------------------------------
function hfound = synccomps_w_frames(this, hfound, frames)

hframes = get(this, 'Frames');

hFig = get(this, 'FigureHandle');
hv   = get(hFig, 'HandleVisibility');
set(hFig, 'HandleVisibility', 'On');

for i = 1:length(hfound),
    if isempty(hfound{i}),
        
        % If hfound is empty we need to create the frame
        hfound{i} = feval(frames(i).constructor);
                
        setcomponentstate(this, this.PreviousState, hfound{i});
        
        % Add the new component to the component list.
        addcomponent(this, hfound{i});
        
        if isa(hfound{i}, 'fdadesignpanel.abstractfiltertype'),
            
            % If the new component is from the designpanel package,
            % render it using the old frames (if possible)
            hnewframes = render(hfound{i}, hframes, hFig);
            
            % If new frames were created, add them to the frames list.
            if isempty(hnewframes),
                hc = allchild(hfound{i});
                if length(hc) == 1,
                    set(hfound{i}, 'Visible', get(hc, 'Visible'));
                end
            else
                addtoframes(this, hnewframes);
                %                 addtocomps(this, hnewframes);
            end
            
        else
            render(hfound{i}, hFig);
            addtoframes(this, hfound{i});
        end
        if isempty(frames(i).setops),
            set(hfound{i}, 'Enable', this.Enable);
        else
            set(hfound{i}, 'Enable', this.Enable, frames(i).setops{:});
        end

    else
        
        % If we are in a "Loading" state, we want to ignore all set
        % operations specified for the frame.  We will be getting these
        % from the loading state.
        if isempty(frames(i).setops) || this.IsLoading
            set(hfound{i}, 'Enable', this.Enable);
        else
            set(hfound{i}, 'Enable', this.Enable, frames(i).setops{:});
        end
        
        if isa(hfound{i}, 'fdadesignpanel.abstractfiltertype'),
            associate(hfound{i}, hframes, hFig);
        end
    end
end

set(hFig, 'HandleVisibility', hv);

hfound = [hfound{:}];


% ------------------------------------------------------------
function disablehnots(hnot)

for i = 1:length(hnot),
    if isa(hnot(i), 'fdadesignpanel.abstractfiltertype'),
        disassociate(hnot(i));
        
        % Disassociate first before setting visible off.  This will eliminate flicker.
        % We will set them invisible later by asking the specsframes which frames they need.
        set(hnot(i), 'Visible', 'Off');
    end
end


% ------------------------------------------------------------
function [hfound, hnot] = parsecomponents(this, frames)

hfound = cell(1,length(frames));

% Find the frames we need to keep and those that we do not.
hnot = allchild(this);
if ~isempty(hnot),
    for indx = 1:length(frames),
        hfound{indx} = getcomponent(this, '-class', frames(indx).constructor);
        if length(hfound{indx}) > 1,
            disconnect(hfound{indx}(1));
            hfound{indx} = hfound{indx}(2);
        end
        
        % Replace the empty handles with true empties to avoid warnings
        % thrown from MATLAB. g323472
        if isempty(hfound{indx})
            hfound{indx} = [];
        end
    end
    hnot = setdiff(hnot, [hfound{:}]);
end


% ------------------------------------------------------------
%   Accessor/Mutator methods
% ------------------------------------------------------------

% ------------------------------------------------------------
function h = getActiveFrames(this)

ha = get(this, 'ActiveComponents');

count = 0;
for indx = 1:length(ha)
    if isa(ha(indx), 'fdadesignpanel.abstractfiltertype'),
        hindx = allchild(ha(indx));
        if ~isempty(hindx),
            count = count+1;
            h(count) = hindx; 
        end
    else
        count = count+1;
        
        h(count) = ha(indx);
    end
end

% ------------------------------------------------------------
function boolflag = isvisprop(h, prop)


try
    v = get(h, prop);
    boolflag = 1;
    if strcmpi(get(h.findprop(prop), 'Visible'), 'off'),
        boolflag = 0;
    end
catch ME %#ok<NASGU>

    boolflag = 0;
end


% ------------------------------------------------------------
function mode = getmode(this)

mode = 'minimum';
hFO  = find(getActiveFrames(this), '-isa', 'siggui.abstractfilterorder');
if ~isempty(hFO),
    mode = get(hFO, 'Mode');
end

% ------------------------------------------------------------
function setMode(this, newMode)

hDM = get(this, 'CurrentDesignMethod');
if isvisprop(hDM, 'ordermode')
    set(hDM, 'OrderMode', newMode);
end

hFO = find(getActiveFrames(this), '-isa', 'siggui.abstractfilterorder');
if ~isempty(hFO),
    set(hFO, 'Mode', newMode);
end

% ------------------------------------------------------------
%   Add to object lists
% ------------------------------------------------------------

% ------------------------------------------------------------
function addlisteners2components(this, varargin)

hFrames = get(this, 'Frames');

listener = [ ...
        handle.listener(union(hFrames, allchild(this)), 'UserModifiedSpecs', ...
        {@listeners, 'usermodifiedspecs_listener'}); ...
        handle.listener(union(hFrames, allchild(this)), 'OrderRequested', ...
        {@listeners, 'orderrequested_listener'}); ...
    ];

set(listener, 'CallbackTarget', this);
set(this, 'UserModifiedListener', listener);

% ------------------------------------------------------------
function addtoframes(this, hnew)

sz = gui_sizes(this);

figpos = [770 549]*sz.pixf;

resizefcn(hnew, figpos);

hframes = get(this, 'Frames');

if isempty(hframes),
    hframes = hnew;
else
    hframes(end+1) = hnew;
end

set(this, 'Frames', hframes);

% ------------------------------------------------------------
function staticremezlp(hax)
% This is another speed hack.  Hard code the lowpass remez staticresp.

xlim = [0 1.1];
ylim = [0 1.7];

xtick = 1;
xticklabel = 'Fs/2'; 

ytick = [-1 1];
yticklabel = 0;

set(hax,...
    'Color','white',...
    'Xlim',xlim,...
    'Ylim',ylim,...
    'Xtick',xtick,...
    'Xticklabel',xticklabel,...
    'Ytick',ytick,...
    'Yticklabel',yticklabel,...
    'Box','off',...
    'Clipping','off',...
    'Layer','Top',...
    'Plotboxaspectratio',[2 .8 1]);

x=[0,0,-0.0075,0,0.0075,0,0];
y=[1.7000    1.6200    1.6200    1.7000    1.6200    1.6200    1.7000];

patch(x, y, [.8 .8 .8],...
    'facecolor',[0 0 0],...
    'edgecolor','black',...
    'clipping','off',...
    'Parent',hax);
x = [1.1,1.07333333333333,1.07333333333333,1.1,1.07333333333333,...
        1.07333333333333,1.1];
y = [0         0    0.0262         0   -0.0262         0         0];

patch(x, y, [.8 .8 .8],...
    'facecolor',[0 0 0],...
    'edgecolor','black',...
    'clipping','off',...
    'Parent',hax);
text(.01,-.1,'0','Parent',hax);

xaxStr = 'f (Hz)';
yaxStr = 'Mag. (dB)';
text(1.1,-.1,xaxStr,'Parent',hax);
text(.015,1.7-.1,yaxStr,'Parent',hax);
%----------------------------------------------
% idealFiltResMag =  [1 1     1     0];
% idealFiltResFreq = [0 .45 .45 .45]; 
%-----------------------------------------------
x = [0    0.4000    0.4000         0];
y = [1.1000    1.1000    1.2500    1.2500];
faceColor = get(0,'defaultuicontrolbackgroundcolor') * 1.07;
faceColor(faceColor > 1) = 1;
patch(x, y, [.8 .8 .8],...
    'facecolor',faceColor,...
    'edgecolor','black',...
    'Parent',hax);
line([x(1) x(2)],[y(3) y(3)],...
    'color','white',...
    'Parent',hax);
y = [0         0    0.9000    0.9000];
patch(x, y, [.8 .8 .8],...
    'facecolor',faceColor,...
    'edgecolor','black',...
    'Parent',hax);
line([x(1) x(2)],[y(1) y(1)],...
    'color','white',...
    'Parent',hax);
x = [1.0000    0.5000    0.5000    1.0000];
y = [0.1000    0.1000    0.2500    0.2500];
patch(x, y, [.8 .8 .8],...
    'facecolor',faceColor,...
    'edgecolor','black',...
    'Parent',hax);
line([x(1) x(2)],[y(3) y(3)],...
    'color','white',...
    'Parent',hax);
%-----------------------------
ytop = 1.1;
ybot = .9;
String = 'A_{pass}';
xpos = 0.5200;
hl1 = line([xpos-.02 xpos+.02],[ytop ytop],'Parent',hax);
x = [0.5200    0.5200    0.5150    0.5200    0.5250    0.5200    0.5200];
y = [0.6000    0.8300    0.8300    0.9000    0.8300    0.8300    0.6000];
patch( x, y, [.8 .8 .8],...
    'facecolor',[0 0 0],...
    'edgecolor','black',...
    'clipping','off',...
    'Parent',hax);
y = [1.3000    1.1700    1.1700    1.1000    1.1700    1.1700    1.3000];
patch(x, y, [.8 .8 .8],...
    'facecolor',[0 0 0],...
    'edgecolor','black',...
    'clipping','off',...
    'Parent',hax);
hl2 = line([xpos-.02 xpos+.02],[ybot ybot],'Parent',hax);
set([hl1 hl2],'color','black');    
text(xpos+.03,.98,String,'Parent',hax)

xpos = 0.8500;

ytop = 1;
String = 'A_{stop}';
hl1 = line([xpos-.02 xpos+.02],[ytop ytop],'Parent',hax);
set(hl1,'color','black');

x = [0.8500    0.8500    0.8450    0.8500    0.8550    0.8500    0.8500];
y = [0.6500    0.9300    0.9300    1.0000    0.9300    0.9300    0.6500];

patch(x, y, [.8 .8 .8],...
    'facecolor',[0 0 0],...
    'edgecolor','black',...
    'clipping','off',...
    'Parent',hax);
y = [0.4500    0.1800    0.1800    0.1100    0.1800    0.1800    0.4500];
patch(x, y, [.8 .8 .8],...
    'facecolor',[0 0 0],...
    'edgecolor','black',...
    'clipping','off',...
    'Parent',hax);
text(xpos-.02,.55,String,'Parent',hax);

fpassStr0 = 'F_{pass}';
fpass = 0.4000;
text(fpass-.0022,0, '|','Parent',hax);
text(fpass-.035,-.17,fpassStr0,'Parent',hax);
fstop = 0.5000;
fstopStr0 = 'F_{stop}';
text(fstop-.0025,0, '|','Parent',hax);
text(fstop-.025,-.17,fstopStr0,'Parent',hax);

% [EOF]

function varargout = sos(hFDA)
%SOS Launch a convert to SOS dialog linked to FDATool

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.12.4.6 $  $Date: 2006/10/18 03:29:07 $

if qfiltexists,
    c = 'siggui.sosreorderdlg';
else
    c = 'siggui.sos';
end

hSOS = getcomponent(hFDA,'-class', c);

if isempty(hSOS),
    
    filtobj = getfilter(hFDA);
    % Instantiate the SOS conversion dialog box
    hSOS = feval(c, filtobj);
    addcomponent(hFDA,hSOS);
    
    % The first time we generate the object, check to see if we need to set
    s = get(hFDA, 'LastLoadState');
    if isfield(s, 'sosreorderdlg')
        setstate(hSOS, s.sosreorderdlg);
    end
    
    % Render the SOS Dialog, center it and make it visible
    render(hSOS);
    centerdlgonfig(hSOS,hFDA);
    set(hSOS,'Visible','On');
    
    % Add a listener to the Filterupdated property to set the isapplied flag to 0
    addlistener(hFDA, 'FilterUpdated', @sos_filter_listener, hSOS);
    l = handle.listener(hSOS, 'NewFilter', {@filterconverted_eventcb, hFDA});
    setappdata(hSOS.FigureHandle, 'FDATool_sos_listener', l); 
    
else
    set(hSOS, 'Visible', 'On');
    figure(hSOS.FigureHandle);
end

if nargout
    varargout = {hSOS};
end

%-------------------------------------------------------------------------
function filterconverted_eventcb(hObj, eventData, hFDA)

data = get(eventData, 'data');

% If there is no MCode already in FDATool, do not add the scaling code.
if isempty(hFDA.Mcode)
    opts.mcode = [];
else
    opts.mcode = data.mcode;
end

hFDA.setfilter(data.filter, opts);


%-------------------------------------------------------------------------
function sos_filter_listener(hSOS, eventData)

hFDA = get(eventData, 'Source');

Hd = getfilter(hFDA);
if isa(Hd, 'dfilt.abstractsos')
    hSOS.Filter = getfilter(hFDA);
    enab = hFDA.Enable;
else
    enab = 'Off';
end
set(hSOS, 'ENable', enab);

% [EOF]

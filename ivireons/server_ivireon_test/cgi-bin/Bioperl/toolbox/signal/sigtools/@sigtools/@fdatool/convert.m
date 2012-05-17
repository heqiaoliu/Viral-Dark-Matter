function varargout = convert(hFDA)
%CONVERT Launch a convert dialog linked to FDATool

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.12.4.5 $  $Date: 2005/06/16 08:46:49 $

hC = getcomponent(hFDA, '-class','siggui.convert');

if isempty(hC),
    
    filtobj = getfilter(hFDA);

    % Instantiate the Convert Dialog box
    hC = siggui.convert(filtobj,getflags(hFDA, 'calledby','dspblks'));
    addcomponent(hFDA,hC);
    
    % Render the Convert Dialog, center it and make it visible
    render(hC);
    centerdlgonfig(hC,hFDA);
    set(hC,'Visible','On');
    
    % Add a listener to FDATool's filter.
    addlistener(hFDA, 'FilterUpdated', @local_filter_listener,hC);
    l = handle.listener(hC, 'FilterConverted', {@filterconverted_eventcb, hFDA});
    setappdata(hC.FigureHandle, 'FDATool_convert_listener', l);    

else
    set(hC,'Visible','On');
    figure(hC.FigureHandle);
end

if nargout, varargout = {hC}; end

%-------------------------------------------------------------------------
function filterconverted_eventcb(hObj, eventData, hFDA)

data = get(eventData, 'data');

opts.mcode  = data.mcode;
opts.source = sprintf('%s (converted)', strrep(hFDA.filtermadeby, ' (converted)', ''));
opts.source = strrep(opts.source, ' (quantized)', '');

hFDA.setfilter(data.filter, opts);

%-------------------------------------------------------------------------
function local_filter_listener(hC, eventData)

% Get FDATool's handle from the eventData
hFDA    = get(eventData, 'Source');

% Get FDATool's filter
newfilt = getfilter(hFDA);

hC.Filter = newfilt;

% [EOF]

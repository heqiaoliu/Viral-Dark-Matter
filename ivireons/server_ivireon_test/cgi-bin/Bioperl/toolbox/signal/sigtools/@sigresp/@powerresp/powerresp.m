function this = powerresp(varargin)
%POWERRESP Construct a power response object.
%    POWERRESP(H) constructs a power response (PSD) object with the power
%    spectrum specified by the object H.  H must be an object that extends
%    DSPDATA.ABSTRACTPS.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/01/25 23:11:27 $


% Create a response object.
this = sigresp.powerresp;
freqz_construct(this,varargin{:});

% Assign properties.
this.Tag  = 'powerresp';
this.Name = 'Power Spectrum Response';  % Title string

% Create a listeners for properties of the response object.  Use
% getparameter to create a listener for parameter objects.
existinglisteners = this.PowerResponseListeners;
l = [existinglisteners; ...    
    handle.listener(getparameter(this, 'frequnits'),...
    'NewValue',@frequnits_listener)];

%     handle.listener(getparameter(this,this.getmagdisplaytag),...
%     'NewValue',@magnitudedisplay_listener); ...

set(l, 'CallbackTarget', this);
set(this, 'PowerResponseListeners', l);

% At this point the freq units are correct because we get them from the PSD
% data object, so force an update on the ylabel.
freqmode_listener(this,[]);

%--------------------------------------------------------------------------
function magnitudedisplay_listener(this, eventData)
%MAGNITUDEDISPLAY_LISTENER   Listener for the MagnitudeDisplay property.

% Disable the listener that would fire the redraw, because we're already
% firing the redraw for the magntidue display.
cacheState = [];
if isrendered(this),    
    l = get(this, 'UsesAxes_WhenRenderedListeners');
    cacheState = get(l(1),'Enabled');
else                    
    l = [];
end
set(l,'Enabled','Off');

hprm_magdisp  = getparameter(this, getmagdisplaytag(this));
newYlabel     = getsettings(hprm_magdisp, eventData);  % Gets GUI value.
ylabelChoices = get(hprm_magdisp,'ValidValues');

if length(ylabelChoices) > 2, % Only for PSDs

    normalizedUnits = this.NormalizedFrequency;

    if  strcmpi(normalizedUnits,'on') & any(strcmpi(ylabelChoices(1:2),newYlabel)), % psd/hz
        % Change x-axis to Hz if it was normalized.
        this.NormalizedFrequency = 'off';
        
    elseif  strcmpi(normalizedUnits,'off') & strcmpi(ylabelChoices{3},newYlabel),  % psd/rad/sample
        % Change x-axis to rad/sample if it was hz.
        this.NormalizedFrequency = 'on';
    end
end

set(l,'Enabled',cacheState);

% [EOF]

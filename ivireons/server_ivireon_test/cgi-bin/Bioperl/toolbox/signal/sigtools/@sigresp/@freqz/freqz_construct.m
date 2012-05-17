function allPrm = freqz_construct(this,Spectrum,varargin)
%FREQZ_CONSTRUCT Abstract frequency response class.

%   Author(s): P. Pacheco
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2007/12/14 15:20:58 $
    

if nargin > 1,
    if ~isa(Spectrum, 'dspdata.abstractfreqresp'),
        varargin = {Spectrum, varargin{:}};
        Spectrum = [];
    end
else
    Spectrum = [];
end

allPrm = this.freqaxiswfreqrange_construct(varargin{:});

% Convert between on/off and true/false data types for NormalizedFrequency.
if Spectrum.NormalizedFrequency,  normfreq = 'on';
else,                             normfreq = 'off';    
end

if ~isempty(Spectrum),
    set(this,...
        'NormalizedFrequency',normfreq); %,...
%         'FrequencyUnits',Spectrum.Metadata.FrequencyUnits);

    setfreqrange(this,Spectrum);
end

% Ylabels for power response object.
ylabels = getylabels(this);
createparameter(this, allPrm, 'Magnitude Display',...
    getmagdisplaytag(this),ylabels,2);

% Add a frequency range parameter object that is a static text box.
%createparameter(hObj, allPrm, name, tag, varargin)
name = 'Freq. Range Values';
createparameter(this,allPrm,name,getfreqrangevaluestag(this),@lcl_ischar,'[0  1]');
set(this, 'StaticParameters', {getfreqrangevaluestag(this)});

% Create a listeners for properties of the response object.  Use
% getparameter to create a listener for parameter objects.
l = [ ...
        handle.listener(this, this.findprop('Spectrum'), ...
        'PropertyPostSet', @spectrum_listener), ...              
        handle.listener(this,this.findprop('FrequencyRange'), ...
        'PropertyPostSet',@freqrange_listener), ...
    ];

set(l, 'CallbackTarget', this);
set(this, 'PowerResponseListeners', l);

this.Spectrum = Spectrum;

usedefault(this.Parameters, gettoolname(this));

%--------------------------------------------------------------------------
function spectrum_listener(this, eventData)

update_range(this);
setfreqrangeopts(this, []);

%--------------------------------------------------------------------------
function lcl_ischar(userrange)

if ~isempty(userrange) & ~ischar(userrange),
    error(generatemsgid('MustBeAString'),'Invalid frequency range.  Frequency range must be a string.');
end

%--------------------------------------------------------------------------
function freqrange_listener(this, eventData)
%FREQRANGE_LISTENER   Listener for the FrequencyRange property.

% Update the frequency range static text when a new frequency range is
% selected.
update_range(this);

%--------------------------------------------------------------------------
function setfreqrange(this,hpsd)
%SETFREQRANGE Set the frequency range.
%             Set the range based on the frequency units and spectrum type.

% Get all possible frequency range options based on the units.
rangeOpts = getfreqrangeopts(this);

% Determine frequency range based on spectrum type.
% Using idx assumes rangeopts is in the following order:
%    1-half, 2-wholepos, 3-negnpos

if ishalfnyqinterval(hpsd),
    idx = 1;  % Half the Nyquist interval.
elseif getcenterdc(hpsd),
    idx = 3;  % Negative and positive frequencies.
else
    idx = 2;  % Full Nyquist interval: [0, Fs) or [0, pi).
end
this.FrequencyRange = rangeOpts{idx};

% [EOF]

function this = fvtool(varargin)
%FVTOOL The constructor for the FVTool object.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.20.4.4 $  $Date: 2009/07/27 20:32:13 $

this = siggui.fvtool;

% Parse the FVTools' inputs 
[filtobj, hPrms] = parseinputs(this, varargin{:});

this.Filters = filtobj; % xxx UDD Limitation

installanalyses(this);

set(this, 'Tag', 'fvtool');
set(this, 'Version', 1);
hPrms = getparams(hPrms); 

set(this, 'Parameters', hPrms); 

l = [ ...
        handle.listener(this,this.findprop('Analysis'), ...
        'PropertyPostSet',{@listeners, 'analysis_listener'}); ...
        handle.listener(this,this.findprop('OverlayedAnalysis'), ...
        'PropertyPostSet',{@listeners, 'secondanalysis_listener'}); ...
    ];
set(l, 'CallbackTarget', this);
set(this, 'AnalysisListeners', l);

%------------------------------------------------------------------- 
function hPrms = getparams(hPrms) 

if ispref('SignalProcessingToolbox', 'DefaultParameters'),
    p = getpref('SignalProcessingToolbox', 'DefaultParameters');
    
    % Backwards compatibility.  The freqmode used to be save as 1 or 2, but now
    % must be resaved as 'on' or 'off';
    if ~isempty(p) & isfield(p, 'fvtool') & isfield(p.fvtool, 'freqmode')
        if isnumeric(p.fvtool.freqmode)
            if p.fvtool.freqmode == 1,
                p.fvtool.freqmode = 'on';
            elseif p.fvtool.freqmode == 2,
                p.fvtool.freqmode = 'off';
            end
            setpref('SignalProcessingToolbox', 'DefaultParameters', p);
        end
    end
end

if isempty(hPrms) || isempty(find(hPrms, 'Tag', 'freqmode')), 
    hPrm = sigdatatypes.parameter('Normalized Frequency', 'freqmode', 'on/off', 'on'); 
    usedefault(hPrm, 'fvtool');
    if isempty(hPrms), hPrms = hPrm;
    else,              hPrms = [hPrms(:); hPrm]; end
end

%-------------------------------------------------------------------
function [Hd, hPrms] = parseinputs(this, varargin)
% Parse FVTool's inputs
%
%   Outputs:
%     filt        - Cell array of dfilt object(s)
%     analysisStr - Analysis string (e.g., phase, impulse)
%     optinputs   - Structure of optional input arguments

hPrms = [];
if nargin < 2,
    Hd    = [];
else
    
    for indx = 1:length(varargin),
        if isa(varargin{indx}, 'sigdatatypes.parameter'),
            hPrms = varargin{indx};
            break
        end
    end
    
    Hd = this.findfilters(varargin{:});
end

%-------------------------------------------------------------------
function installanalyses(this)

labels = {xlate('Magnitude Response'), ...
        xlate('Phase Response'), ...
        xlate('Magnitude and Phase Responses'), ...
        xlate('Group Delay Response'), ...
        xlate('Phase Delay'), ...
        xlate('Impulse Response'), ...
        xlate('Step Response'), ...
        xlate('Pole/Zero Plot'), ...
        xlate('Filter Coefficients'), ...
        xlate('Filter Information'), ...
        ''};
tags = {'magnitude', 'phase', 'freq', 'grpdelay', 'phasedelay', ...
        'impulse', 'step', 'polezero', 'coefficients', 'info', 'tworesps'};
fcns = {'filtresp.magnitude', 'filtresp.phasez', @lclmagnphase, 'filtresp.grpdelay', ...
        'filtresp.phasedelay', 'filtresp.impz', 'filtresp.stepz', 'filtresp.zplane', ...
        'filtresp.coefficients', 'filtresp.info', {@lcltworesps, this}};

load(fullfile(matlabroot, 'toolbox','signal','sigtools','private','filtdes_icons'));

% Cell array of cdata (properties) for the toolbar icons 
pushbtns = {bmp.mag, ...
        bmp.phase, ...
        bmp.magnphase, ...
        bmp.grpdelay, ...
        bmp.phasedelay, ...
        bmp.impulse, ...
        bmp.step, ...
        bmp.polezero, ...
        bmp.coeffs, ...
        bmp.info, ...
        []};

accels = {'M', '', '', 'G', '', 'R', '', '', '', '', ''};

% Loop over the analyses and install them into FVTool
for i = 1:length(labels)
    s.(tags{i}).label = labels{i};
    s.(tags{i}).fcn   = fcns{i};
    s.(tags{i}).icon  = pushbtns{i};
    s.(tags{i}).accel = accels{i};
    s.(tags{i}).check = [];
end

set(this, 'AnalysesInfo', s);

% ---------------------------------------------------------------
function h2 = lclmagnphase(varargin)

h    = filtresp.magnitude(varargin{:});
h(2) = filtresp.phasez(varargin{:}, getparameter(h));
h2   = filtresp.tworesps(h);

% ---------------------------------------------------------------
function h2 = lcltworesps(this, varargin)

f = get(this, 'Analysis');
s = get(this, 'OverlayedAnalysis');

h    = getanalysisobject(this, f, true);
h(2) = getanalysisobject(this, s, true);

h2 = filtresp.tworesps(h);

% [EOF]

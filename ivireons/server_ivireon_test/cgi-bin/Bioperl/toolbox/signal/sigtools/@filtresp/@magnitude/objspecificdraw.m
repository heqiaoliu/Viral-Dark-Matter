function [m, xunits] = objspecificdraw(this)
%OBJSPECIFICTHISDRAW Draw the magnitude response

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.4.6.15 $  $Date: 2009/01/05 17:59:59 $

% MAIN CHANGES:
%  1 - increased modularity via "procedural decomposition"
%      recommend: decompose into multiple functions
%                 definitions of input and output args will help
%                 code maintenance and modularity tremendously
%  2 - inconsistent usage of "get(obj,field)" versus "obj.field"
%      recommend: obj.field for efficiency
%  3 - usage of LOWER and UPPER case of a variable name (h and H)
%      recommend: don't do that!  works, but poor practice
%                 no changes made ... left both "h" and "H" in code
%  4 - using new ylimit estimator only for dB plots
%      using different estimator for linear plots

% Get handles and filters
h  = this.Handles; % fields get added to struct throughout function
Hd = this.Filters;
h.axes = h.axes(end);

RemoveUserDefinedMask(h);

[xunits,m,h] = InstallMagPlot(h,this,Hd);
hylbl        = InstallYLabel(h,this);
h            = InstallContextMenu(h,this,hylbl);
h            = InstallUserDefinedMask(h,this,Hd,m);

% Store handles
this.Handles = h;
updatemasks(this);

%% --------------------------------------------------------------------
function RemoveUserDefinedMask(h)
% Remove user-defined mask, if it exists

if isfield(h,'userdefinedmask')
    % Note: cannot combine these two statements (isfield and ishandle)
    %       since ishandle will return empty when its arg is empty
    if ishghandle(h.userdefinedmask)
        delete(h.userdefinedmask);
    end
end

%% --------------------------------------------------------------------
function h = InstallUserDefinedMask(h,this,Hd,m)
% Install user-defined display mask

hUDM = this.UserDefinedMask;
if ~isempty(hUDM) & hUDM.EnableMask
    if validate(hUDM)
        switch lower(this.MagnitudeDisplay)
            case 'magnitude (db)'
                mag = 'db';
            case {'magnitude', 'zerophase'}
                mag = 'linear';
            case 'magnitude squared'
                mag = 'squared';
        end

        hUDM = copy(hUDM);
        fs = getmaxfs(Hd);
        if isempty(fs)
            fs = 1;
        end
        
        hUDM.normalizefreq(strcmpi(this.NormalizedFrequency, 'on'), fs*m);

        hUDM.MagnitudeUnits = mag;
        h.userdefinedmask = draw(hUDM, h.axes);

        xdata = get(h.userdefinedmask, 'XData');
        xlim  = get(h.axes, 'XLim');

        % Check that the mask didn't overrun the axes.  Add a fudge factor.
        if any(xdata > xlim(2)*1.01) || any(xdata < xlim(1))
            warning(sprintf('%s\n%s', 'User Defined Mask plotted beyond axes borders.', ...
                'Change the frequency vector of the mask or the frequency range of the response.'));
        end
    else
        warning(sprintf('%s %s', 'Cannot show the User Defined Mask because', ...
            'the frequency vector is not the same length as the magnitude vector.'));
        h.userdefinedmask = [];
    end
else
    h.userdefinedmask = [];
end

%% --------------------------------------------------------------------
function h = InstallContextMenu(h,this,hylbl)
% Install the context menu for changing units of the Y-axis.

if ~ishandlefield(this, 'magcsmenu'),
    h.magcsmenu = contextmenu(getparameter(this, 'magnitude'), hylbl);
end

%% --------------------------------------------------------------------
function [xunits,m,h] = InstallMagPlot(h,this,Hd)
% Compute and plot magnitude filter response
% Set appropriate viewing limits

if ~isempty(Hd)
    % One or more filter responses to view
    %
    [H,W] = ComputeMagResponse(h,this,Hd);
    
    % Normalize frequency axis, and draw response
    %
    [W, m, xunits] = normalize_w(this, W);
    if ishandlefield(this,'line') && length(h.line) == size(H{1}, 2)
        for indx = 1:size(H{1}, 2)
            set(h.line(indx), 'xdata',W{1}, 'ydata',H{1}(:,indx));
        end
    else
        h.line = freqplotter(h.axes, W, H);
    end

else
    % No filters to view - use defaults:
    %
    xunits = '';
    m      = 1;
    h.line = [];
end

% Store the engineering units factor, even if Hd is empty:
setappdata(h.axes, 'EngUnitsFactor', m);

%% --------------------------------------------------------------------
function hylbl = InstallYLabel(h,this)
%Compute y-axis label for display

ylbl = this.MagnitudeDisplay;
if strcmpi(ylbl,'zero-phase')
    ylbl = 'Amplitude';
end
if strcmpi(this.NormalizeMagnitude,'on')
    switch lower(this.MagnitudeDisplay)
        case {'magnitude','magnitude squared','zero-phase'}
            ylbl = sprintf('%s (normalized to 1)', ylbl);
        case 'magnitude (db)'
            ylbl = sprintf('%s (normalized to 0 dB)', ylbl);
    end
end
% Set the new y-axis label into display:
hylbl = ylabel(h.axes, xlate(ylbl));

%% --------------------------------------------------------------------
function [H,W] = ComputeMagResponse(h,this,Hd)
% Compute desired magnitude response of Hd

opts = getoptions(this);
optsstruct.showref  = showref(this.FilterUtils);
optsstruct.showpoly = showpoly(this.FilterUtils);
optsstruct.sosview  = this.SOSViewOpts;

% Compute main response function
%
if strcmpi(this.MagnitudeDisplay,'zero-phase')
    [H, W] = zerophase(Hd, opts{:}, optsstruct);
else
    [H, W] = freqz(Hd, opts{:}, optsstruct);
end

% Normalize magnitude response
%
if strcmpi(this.NormalizeMagnitude, 'on')
    for indx = 1:length(H)
        H{indx} = H{indx}/max(H{indx}(:));
    end
end

% Compute desired response curve
%
switch lower(get(this, 'MagnitudeDisplay'))
    case 'magnitude'
        for indx = 1:length(H)
            H{indx} = abs(H{indx});
        end
    case 'magnitude squared'
        for indx = 1:length(H)
            H{indx} = convert2sq(abs(H{indx}));
        end
    case 'magnitude (db)'
        for indx = 1:length(H)
            H{indx} = convert2db(H{indx});
        end
    case 'zero-phase'
        % NO OP
end

% [EOF]

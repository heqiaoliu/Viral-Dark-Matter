function attachListeners(this)
% attach listeners to all radio and push buttons

% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/05/19 23:05:10 $

% buttons
set(this.UIs.ApplyBtn,'Callback',@(es,ed)LocalApplyBtnCallback(this));
set(this.UIs.CloseBtn,'Callback',@(es,ed)close(this.Dialog));
set(this.UIs.HelpBtn,'Callback',@(es,ed)LocalHelpBtnCallback(this));


%--------------------------------------------------------------------------
function LocalApplyBtnCallback(this)
% Apply button callback

Rstr = get(this.UIs.EditBox,'string');
switch lower(this.Type)
    case 'time'
        msg = 'Time range must be vector of real and increasing values.';
        idr = 'Ident:idguis:rangedlgInvalidTimeRange';
    case 'frequency'
        msg = 'Frequency vector must be vector of real, positive and increasing values.';
        idr = 'Ident:idguis:rangedlgInvalidFreqRange';
    case 'nonlinear'
        msg = 'Regressor range must be vector with two entries representing a valid range.';
        idr = 'Ident:idguis:rangedlgInvalidRegRange';
    case 'samples'
        msg = 'Enter a positive integer (>2) for number of samples used for each regressor.';
        idr = 'Ident:idguis:rangedlgInvalidSamp';
end

try
    r = evalin('base',Rstr);
    if ~isfloat(r) || ~all(isfinite(r)) || ~isrealvec(r) || any(diff(r)<0) ||...
            (strcmpi(this.Type,'frequency') && any(r<0)) || ...
            (strcmpi(this.Type,'nonlinear') && (numel(r)~=2 || r(2)<=r(1)))|| ...
            (strcmpi(this.Type,'samples') && (~isscalar(r) || r<2))
        error(idr,msg);
    end
catch E
    errordlg(idlasterr(E),'Invalid Range','modal')
    %set(this.UI.EditBox,'string','[ ]');
    return
end

if strcmpi(this.Type,'samples')
    this.PlotObj.updateNumSample(r);
else
    this.PlotObj.updateRange(r,this.Type);
end
%--------------------------------------------------------------------------
function LocalHelpBtnCallback(this)
% show help

switch lower(this.Type)
    case 'time'
        iduihelp('idnos.hlp','Time Span');
    case 'frequency'
        iduihelp('idfreq.hlp','Frequency Values');
    case {'nonlinear', 'samples'}
        % todo:
        iduihelp('nlinputrange.htm','Help: Ranges for Nonlinearity Plots');
end

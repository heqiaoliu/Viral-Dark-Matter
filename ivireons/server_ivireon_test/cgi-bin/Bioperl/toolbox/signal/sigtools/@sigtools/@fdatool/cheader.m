function varargout = cheader(this)
%CHEADER Launch the export 2 cheader dialog

%   Author: J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.21.4.9 $  $Date: 2007/12/14 15:21:04 $

Hd = getfilter(this);

if ~issupported(Hd)
    error(generatemsgid('GUIErr'),'Only single-stage single-rate and non-coupled-allpass lattice and non-delay filters can be exported to C.');
end

hEH = getcomponent(this, '-class', 'siggui.exportheader');

% If hEH is empty the Export2CHeaderFile component has not been installed.
if isempty(hEH),

    hFig = get(this, 'FigureHandle');

    % Instantiate the Export Header dialog
    hEH = siggui.exportheader(Hd);
    addcomponent(this, hEH);

    s = get(this, 'LastLoadState');
    if isfield(s, 'exportheader')
        setstate(hEH, s.exportheader);
    end

    % Render the Export Header dialog
    render(hEH);
    hEH.centerdlgonfig(hFig);

    addlistener(this, 'FilterUpdated', {@filterlistener, hEH});
end

% Make the dialog visible and bring it to the front.
set(hEH, 'Visible', 'On');
figure(hEH.FigureHandle);

if nargout, varargout = {hEH}; end

%-------------------------------------------------------------------
function filterlistener(this, eventData, hEH)
% Function is executed whenever the filter of FDATool is modified

Hd = getfilter(this);

if issupported(Hd)

    % When there is a new filter, or the UndoManager has performed an action
    % Sync the filters of FDATool and ExportHeader
    hEH.Filter = getfilter(this);
    enab = this.Enable;
else
    enab = 'off';
end

set(hEH, 'Enable', enab);

% ----------------------------------------------------------------------
function b = issupported(Hd)

b = isa(Hd, 'dfilt.singleton') && ~isa(Hd, 'dfilt.calattice') && ~isa(Hd, 'dfilt.delay');

% [EOF]

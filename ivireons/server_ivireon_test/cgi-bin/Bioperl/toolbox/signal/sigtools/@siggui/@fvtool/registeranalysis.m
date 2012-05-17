function [hmenu, htoolbar] = registeranalysis(hFVT, lbl, tag, fcn, icon, accel, checkfcn)
%REGISTERANALYSIS Register a new analysis with FVTool
%   REGISTERANALYSIS(hFVT, LABEL, TAG, FCN) Register a new analysis with the
%   session of FVTool associated with hFVT.  When the analysis is selected FCN
%   will be feval'ed with hFVT as the first input argument.
%
%   REGISTERANALYSIS(hFVT, LABEL, TAG, FCN, ICON, ACCEL)

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.12.4.3 $  $Date: 2010/05/20 03:10:36 $

error(nargchk(4,7,nargin,'struct'));

if nargin < 5, icon     = []; end
if nargin < 6, accel    = ''; end
if nargin < 7, checkfcn = []; end

info = get(hFVT, 'AnalysesInfo');

% If the tag is already in use, error out.
if ~isempty(info) && isfield(info, tag),
    error(generatemsgid('InvalidParam'),'The tag ''%s'' is already in use.',tag);
end

info.(tag) = lclbuildstruct(lbl, fcn, icon, accel, checkfcn);

% Save the information in the object
set(hFVT,'AnalysesInfo',info);

% Announce a new analysis
eventData = sigdatatypes.sigeventdata(hFVT, 'NewAnalysis', tag);
send(hFVT, 'NewAnalysis', eventData);

% Return the handle to the new controls if the GUI is rendered
if isrendered(hFVT),
    h        = get(hFVT,'Handles');
    if isfield(h.menu.analyses, tag),
        hmenu = h.menu.analyses.(tag);
    else
        hmenu = [];
    end
    if isfield(h.toolbar.analyses, tag),
        htoolbar = h.toolbar.analyses.(tag);
    else
        hmenu = [];
    end
else
    hmenu    = [];
    htoolbar = [];
end

% ---------------------------------------------------------- 
function s = lclbuildstruct(lbl, fcn, icon, accel, checkfcn) 

s.label = lbl;
s.fcn   = fcn;
s.icon  = icon;
s.accel = accel;
s.check = checkfcn;

% [EOF]

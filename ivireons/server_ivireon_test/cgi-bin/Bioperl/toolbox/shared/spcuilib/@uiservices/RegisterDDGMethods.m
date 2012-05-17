function RegisterDDGMethods(hDerived,select)
%RegisterDDGMethods Register basic dialog methods.
%   These must get registered for each derived dialog.
%
% Select should be a cell-array of strings,
% containing one or more of the following:
%    'getdialogschema','validate','closedlg','getdisplayicon'
%
% Called in schema for derived class as:
%   uiservices.RegisterDDGMethods(hDerivedObject);

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/06/11 16:06:22 $

allSelections = {'getdialogschema','preapply','closedlg','getdisplayicon'};
if nargin<2,
    select=allSelections;
end
if any(strcmpi(allSelections{1},select))
    m = schema.method(hDerived, 'getDialogSchema');
    s = m.Signature;
    s.varargin    = 'off';
    s.InputTypes  = {'handle', 'string'};
    s.OutputTypes = {'mxArray'};
end
if any(strcmpi(allSelections{2},select))
    m = schema.method(hDerived, 'preApply');
    s = m.Signature;
    s.varargin    = 'off';
    s.InputTypes  = {'handle'};
    s.OutputTypes = {'bool','string'};
end
if any(strcmpi(allSelections{3},select))
    m = schema.method(hDerived, 'closedlg');
    s = m.Signature;
    s.varargin    = 'off';
    s.InputTypes  = {'handle'};
end
if any(strcmpi(allSelections{4},select))
    m = schema.method(hDerived, 'getDisplayIcon');
    s = m.Signature;
    s.varargin    = 'off';
    s.InputTypes  = {'handle'};
    s.OutputTypes = {'string'};
end

% [EOF]

function schema

%   Author: A. Stothert
%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:54:56 $

%% Class Definition
%
% Class for the Check Linear Step Response Characteristics block dialog
%
hParentPkg = findpackage('slctrlblkdlgs');
hParent    = findclass(hParentPkg, 'absCheckFrequencyDlg');
hPackage   = findpackage('slctrlblkdlgs');
hThisClass = schema.class(hPackage, 'CheckLinStepDlg', hParent);

%% Class Methods
% getDialogSchema
m = schema.method(hThisClass, 'getDialogSchema');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'string'};
s.OutputTypes = {'mxArray'};
% configBlk
m = schema.method(hThisClass,'configBlk','Static');
s = m.Signature;
s.varargin   = 'off';
s.InputTypes = {'handle'};
s.OutputType = {};
% getBounds
m = schema.method(hThisClass,'getBounds','Static');
s = m.Signature;
s.varargin   = 'off';
s.InputTypes = {'handle'};
s.OutputType = {};
% setBounds
m = schema.method(hThisClass,'setBounds','Static');
s = m.Signature;
s.varargin    = 'on';
s.InputTypes  = {'handle','mxArray','mxArray'};
s.OutputTypes = {};
% supportsMIMO
m = schema.method(hThisClass,'supportsMIMO','Static');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {};
s.OutputTypes = {'bool'};
% getDefaultPos
m = schema.method(hThisClass,'getDefaultPos','Static');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {};
s.OutputTypes = {'mxArray'};
% callbackBounds
m = schema.method(hThisClass,'callbackBounds');
m.Signature.varargin    = 'off';
m.Signature.InputTypes  = {'handle','string','handle'};
m.Signature.OutputTypes = {};
% preApplySVDCallback
m = schema.method(hThisClass,'preApplyLinStepCallback');
m.Signature.varargin    = 'off';
m.Signature.InputTypes  = {'handle','handle'};
m.Signature.OutputTypes = {'bool','string'};
% postApplySVDCallback
m = schema.method(hThisClass,'postApplyLinStepCallback');
m.Signature.varargin    = 'off';
m.Signature.InputTypes  = {'handle','handle'};
m.Signature.OutputTypes = {'bool','string'};

%% Class Properties
%Properties relating to step response characteristics
schema.prop(hThisClass,'EnableStepResponseBound','bool');
schema.prop(hThisClass,'FinalValue','string');
schema.prop(hThisClass,'RiseTime','string');
schema.prop(hThisClass,'PercentRise','string');
schema.prop(hThisClass,'SettlingTime','string');
schema.prop(hThisClass,'PercentSettling','string');
schema.prop(hThisClass,'PercentOvershoot','string');
schema.prop(hThisClass,'PercentUndershoot','string');


function schema

%   Author: A. Stothert
%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:55:37 $

%% Class Definition
%
% Class for the Check Bode Characteristics block dialog
%
hParentPkg = findpackage('slctrlblkdlgs');
hParent    = findclass(hParentPkg, 'absCheckFrequencyDlg');
hPackage   = findpackage('slctrlblkdlgs');
hThisClass = schema.class(hPackage, 'CheckPZMapDlg', hParent);

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
% preApplyBodeCallback
m = schema.method(hThisClass,'preApplyPZMapCallback');
m.Signature.varargin    = 'off';
m.Signature.InputTypes  = {'handle','handle'};
m.Signature.OutputTypes = {'bool','string'};
% postApplyBodeCallback
m = schema.method(hThisClass,'postApplyPZMapCallback');
m.Signature.varargin    = 'off';
m.Signature.InputTypes  = {'handle','handle'};
m.Signature.OutputTypes = {'bool','string'};

%% Class Properties
%Properties relating to settling time
schema.prop(hThisClass,'EnableSettlingTime','bool');
schema.prop(hThisClass,'SettlingTime','string');
%Properties relating to overshoot
schema.prop(hThisClass,'EnablePercentOvershoot','bool');
schema.prop(hThisClass,'PercentOvershoot','string');
%Properties relating to damping ratio
schema.prop(hThisClass,'EnableDampingRatio','bool');
schema.prop(hThisClass,'DampingRatio','string');
%Properties relating to natural frequency
schema.prop(hThisClass,'EnableNaturalFrequency','bool');
schema.prop(hThisClass,'NaturalFrequency','string');
schema.prop(hThisClass,'NaturalFrequencyBound','string');

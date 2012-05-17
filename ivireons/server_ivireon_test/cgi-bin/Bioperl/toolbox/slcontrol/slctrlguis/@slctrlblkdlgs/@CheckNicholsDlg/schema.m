function schema

%   Author: A. Stothert
%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2010/05/10 17:57:59 $

%% Class Definition
%
% Class for the Check Bode Characteristics block dialog
%
hParentPkg = findpackage('slctrlblkdlgs');
hParent    = findclass(hParentPkg, 'absCheckFrequencyDlg');
hPackage   = findpackage('slctrlblkdlgs');
hThisClass = schema.class(hPackage, 'CheckNicholsDlg', hParent);

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
m = schema.method(hThisClass,'preApplyNicholsCallback');
m.Signature.varargin    = 'off';
m.Signature.InputTypes  = {'handle','handle'};
m.Signature.OutputTypes = {'bool','string'};
% postApplyBodeCallback
m = schema.method(hThisClass,'postApplyNicholsCallback');
m.Signature.varargin    = 'off';
m.Signature.InputTypes  = {'handle','handle'};
m.Signature.OutputTypes = {'bool','string'};

%% Class Properties
%Properties relating to gain & phase margins
schema.prop(hThisClass,'EnableMargins','bool');
schema.prop(hThisClass,'GainMargin','string');
schema.prop(hThisClass,'PhaseMargin','string');
%Properties relating to Gain-phase bound
schema.prop(hThisClass,'EnableGainPhaseBound','bool');
schema.prop(hThisClass,'GainPhaseBoundType','string');
schema.prop(hThisClass,'OLPhases','string');
schema.prop(hThisClass,'OLGains','string');
%Properties relating to Closed-Loop peak gain
schema.prop(hThisClass,'EnableCLPeakGain','bool');
schema.prop(hThisClass,'CLPeakGain','string');
%Property for closed loop feedback sign
%Property for closed loop feedback sign
if isempty( findtype('slctrlblkdlgs_enumFeedbackSign') )
   schema.EnumType('slctrlblkdlgs_enumFeedbackSign',{'-1', '+1'});
end
schema.prop(hThisClass,'FeedbackSign','slctrlblkdlgs_enumFeedbackSign');

function schema

%   Author: A. Stothert
%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2010/04/30 00:44:06 $

%% Class Definition
%
% Class for the Check Bode Characteristics block dialog
%
hParentPkg = findpackage('slctrlblkdlgs');
hParent    = findclass(hParentPkg, 'absCheckFrequencyDlg');
hPackage   = findpackage('slctrlblkdlgs');
hThisClass = schema.class(hPackage, 'CheckMarginsDlg', hParent);

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
% callbackView
m = schema.method(hThisClass,'showView');
m.Signature.varargin = 'off';
m.Signature.InputTypes={'handle','handle'};
m.Signature.OutputTypes={};
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
% preApplyMarginsCallback
m = schema.method(hThisClass,'preApplyMarginsCallback');
m.Signature.varargin    = 'off';
m.Signature.InputTypes  = {'handle','handle'};
m.Signature.OutputTypes = {'bool','string'};
% postApplyMarginsCallback
m = schema.method(hThisClass,'postApplyMarginsCallback');
m.Signature.varargin    = 'off';
m.Signature.InputTypes  = {'handle','handle'};
m.Signature.OutputTypes = {'bool','string'};

%% Class Properties
%Properties relating to gain & phase margins
schema.prop(hThisClass,'EnableMargins','bool');
schema.prop(hThisClass,'GainMargin','string');
schema.prop(hThisClass,'PhaseMargin','string');
%Property for closed loop feedback sign
if isempty( findtype('slctrlblkdlgs_enumFeedbackSign') )
   schema.EnumType('slctrlblkdlgs_enumFeedbackSign',{'-1', '+1'});
end
schema.prop(hThisClass,'FeedbackSign','slctrlblkdlgs_enumFeedbackSign');
%Properties relating to plot type
if isempty( findtype('slctrlblkdlgs_enumGPMPlotType') )
   schema.EnumType('slctrlblkdlgs_enumGPMPlotType',{'bode', 'nichols', 'nyquist', 'table'});
end
schema.prop(hThisClass,'PlotType','slctrlblkdlgs_enumGPMPlotType');
p = schema.prop(hThisClass,'newPlotPostApply','bool');
p.FactoryValue = false;

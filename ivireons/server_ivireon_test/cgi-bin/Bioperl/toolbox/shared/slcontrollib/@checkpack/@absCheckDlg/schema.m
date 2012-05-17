function schema

%   Author: A. Stothert
%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:51:27 $

%% Class Definition
%
% Abstract parent class for all check dialog classes.
%
hParentPkg = findpackage('Simulink');
hParent    = findclass(hParentPkg, 'SLDialogSource');
hPackage   = findpackage('checkpack');
hThisClass = schema.class(hPackage, 'absCheckDlg', hParent);

%% Class Methods
% callbackAssertion
m = schema.method(hThisClass,'callbackAssertion');
m.Signature.varargin = 'off';
m.Signature.InputTypes={'handle','string','handle'};
m.Signature.OutputTypes={};
% configBlk
m = schema.method(hThisClass,'configBlk','Static');
m.Signature.varargin = 'off';
m.Signature.InputTypes = {'handle'};
m.Signature.OutputType = {'string'};
% callbackView
m = schema.method(hThisClass,'callbackView');
m.Signature.varargin = 'off';
m.Signature.InputTypes={'handle'};
m.Signature.OutputTypes={};
% loadBlkFcn
m = schema.method(hThisClass,'loadBlkFcn','Static');
m.Signature.varargin = 'off';
m.Signature.InputTypes = {'string'};
m.Signature.OutputTypes={};
% openBlkFcn
m = schema.method(hThisClass,'openBlkFcn','Static');
m.Signature.varargin = 'off';
m.Signature.InputTypes = {'handle'};
m.Signature.OutputTypes={};
% openBlkView
m = schema.method(hThisClass,'openBlkView','Static');
m.Signature.varargin = 'off';
m.Signature.InputTypes = {'handle'};
m.Signature.OutputTypes={};

%% Class Properties
%Properties related to assertion
schema.prop(hThisClass,'enabled','bool');
schema.prop(hThisClass,'callback','string');
schema.prop(hThisClass,'stopWhenAssertionFail','bool');
schema.prop(hThisClass,'export','bool');
%Properties related to visualization
schema.prop(hThisClass,'LaunchViewOnOpen','bool');
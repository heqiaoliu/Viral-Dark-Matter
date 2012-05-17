function schema
% Defines properties for @simulinkTsParentNode class.
%
%   Author(s): Rajiv Singh
%   Copyright 2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $ $Date: 2005/05/27 14:16:48 $


%% Register class (subclass)
p = findpackage('tsguis');
c = schema.class(p, 'simulinkTsParentNode', findclass(p,'tsparentnode'));

% There is a list of disparate object types that could be a node to the
% simulinkTsParentNode. The parent node keeps information on its
% child types.
p = schema.prop(c,'legalChildren','string vector');
p.FactoryValue = {'Simulink.Timeseries', 'Simulink.TsArray',...
    'Simulink.SubsysDataLogs','Simulink.StateflowDataLogs',...
    'Simulink.ScopeDataLogs','Simulink.ModelDataLogs'}; 
p.Description = ['List of all the valid Simulink logged data',...
    ' object types currently allowed in the TSTOOL GUI.'];
p.AccessFlags.PublicSet = 'off';

%schema.prop( c, 'SelectedTableHandle', 'MATLAB array' );

%c = schema.prop();

%Note: @simulinkTsParentNode inherits from @tsparentnode and thus gets two
%events - timeserieschange and tsnamechange. These events are still useful
%and should be listened to because Simulink.Timeseries could be direct
%children of @simulinkTsParentNode.

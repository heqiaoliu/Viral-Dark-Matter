function schema
% SCHEMA  Defines properties for modeltype class

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/10/31 06:12:40 $

% Get handles of associated packages and classes
hCreateInPackage   = findpackage('nlbbpack');

% Construct class
c = schema.class(hCreateInPackage, 'modeltypepanel');

% name of model being estimated %required??
%p = schema.prop(c,'ModelName','string');

% name of initial model %required??
%p = schema.prop(c,'InitialModelNames','string vector');
%p.FactoryValue = {'<none>'};

% array of listeners 
p = schema.prop(c,'Listeners','MATLAB array');

% handle to java gui frame
p = schema.prop(c,'jMainPanel','com.mathworks.mwswing.MJPanel');
p.AccessFlags.PublicSet = 'off';

% handles to java controls
schema.prop(c,'jModelStructureCombo','com.mathworks.mwswing.MJComboBox');
schema.prop(c,'jInitialModelButton' ,'com.mathworks.mwswing.MJButton');
schema.prop(c,'jModelNameLabel'     ,'com.mathworks.mwswing.MJLabel');
schema.prop(c,'jModelNameEditLabel' ,'com.mathworks.mwswing.MJLabel');
schema.prop(c,'InitModelDialog'     ,'MATLAB array');

% udd object handles to main model panels
schema.prop(c,'NlarxPanel','handle'); %idnlarx model estimation widgets
schema.prop(c,'NlhwPanel','handle'); %idnlhw model estimation widgets

schema.prop(c,'Data','MATLAB array');
%modname = nlutilspack.generateUniqueModelName('idnlarx');
% a = struct('ModelName','','ExistingModels',{{'<none>'}},'SelectionIndex',0);
% p.FactoryValue = struct('StructureIndex',0,'idnlarx',a,'idnlhw',a);

%{
%nlarx, nlhw and estim options in the gui
p = schema.prop(c,'NlarxOptions','handle');
p = schema.prop(c,'NlhwOptions','handle');
p = schema.prop(c,'EstimOptions','handle');

% estimation and validation data
%[data,data_info,data_n,handles] = iduigetd(type,mode);
p = schema.prop(c,'EstimData','handle');

% handles to java controls
p = schema.prop(c,'ModelTypeCombo','com.mathworks.mwswing.MJComboBox');
p = schema.prop(c,'EstButton','com.mathworks.mwswing.MJButton');
%}

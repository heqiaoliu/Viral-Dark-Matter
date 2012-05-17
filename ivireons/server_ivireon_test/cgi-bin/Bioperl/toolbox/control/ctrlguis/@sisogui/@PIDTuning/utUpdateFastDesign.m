function utUpdateFastDesign(this)
%

%   Author(s): R. Chen
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2010/05/10 16:59:07 $

Handles = this.SpecPanelHandles;
% get controller type
Index = this.utGetSelectedRadioButton(Handles.GroupTypeRRT);
if Index<=3
    Type = this.ControllerTypesRRT{Index};
else
    UseFilter = 2*double(Handles.CheckboxRRT.isSelected);
    Type = this.ControllerTypesRRT{Index+UseFilter};
end
% get plant model
Model = -this.OpenLoopPlant; 
% create data src object
DataSrc = pidtool.DataSrcLTI(Model,Type,[]);
% get WC
options = pidtuneOptions;
WC = DataSrc.oneclick(options.PhaseMargin);
% set slider
this.DesignObjRRT.initialize(Model.Ts,WC,options.PhaseMargin);


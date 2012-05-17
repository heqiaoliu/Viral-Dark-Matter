function [x,xchar] = getListOfInitialModels(this,Type)
% get list of existing models if the currently selected type
% Type: 'idnlarx' or 'idnlhw' (usually not provided)

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 06:12:33 $

if nargin<2
    Type = this.getCurrentModelTypeID;
end

%x = this.InitModelDialog.Data.(Type).ExistingModels;
xchar = nlutilspack.getAllCompatibleModels(Type,true,false); 
x = nlutilspack.matlab2java(xchar,'vector');

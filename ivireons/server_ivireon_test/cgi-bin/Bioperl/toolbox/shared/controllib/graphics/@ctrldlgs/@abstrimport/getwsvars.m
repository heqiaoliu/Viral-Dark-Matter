function getwsvars(this)
%GETWSVARS Generates the variable list from workspace 
% 

%   Author(s): Craig Buhr, John Glass
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:14:04 $

Vars = evalin('base','whos');
[VarNames, DataModels] = getmodels(this,Vars,'base');
this.updatetable(VarNames,DataModels);
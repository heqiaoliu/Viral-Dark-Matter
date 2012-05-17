function getmatfilevars(this)
% getmatfilevars Generates the variable list from .mat file 
% 

%   Author(s): Craig Buhr, John Glass
%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:14:02 $

PathName = this.LastPath;
FileName = this.FileName;

if ~isempty(FileName)
    FullPathName = fullfile(PathName, FileName);
    try
        Vars = whos('-file',FullPathName);
        [VarNames, DataModels] = getmodels(this,Vars,'file');
    catch ME
        if strcmp(ME.identifier,'MATLAB:whos:fileIsNotThere')
            msg = sprintf('Could not find the file %s.',FullPathName);
        else
            msg = ME.message;
        end
        com.mathworks.mwswing.MJOptionPane.showMessageDialog(this.Frame,msg,...
            xlate('Import Error'),javax.swing.JOptionPane.ERROR_MESSAGE);
        VarNames = {};
        DataModels = {};
    end
else
    VarNames = {};
    DataModels = {};
end

this.updatetable(VarNames,DataModels);

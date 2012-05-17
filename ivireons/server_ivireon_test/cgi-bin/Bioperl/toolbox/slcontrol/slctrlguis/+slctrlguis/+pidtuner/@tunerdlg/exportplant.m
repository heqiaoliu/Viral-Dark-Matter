function exportplant(this)
% EXPORTPLANT exports LTI plant model to base workspace

% Author(s): R. Chen
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2010/04/30 00:43:54 $

checkLabels = {pidtool.utPIDgetStrings('cst','exportdlg_label1'),...
    pidtool.utPIDgetStrings('cst','exportdlg_label2')};
varNames = {'G','C'}; 
G = this.DataSrc.G1;
if this.DataSrc.DOF == 1
    C = pid(this.DataSrc.Cfb);
else
    Sum1 = sumblk('u','ufb','uff','+-');
    Sum2 = sumblk('e','r','y','+-');
    C = connect(this.DataSrc.Cfb,this.DataSrc.Cff,Sum1,Sum2,{'r','y'},'u');
end
items = {G,C};
export2wsdlg(checkLabels,varNames,items,pidtool.utPIDgetStrings('cst','exportdlg_title'));



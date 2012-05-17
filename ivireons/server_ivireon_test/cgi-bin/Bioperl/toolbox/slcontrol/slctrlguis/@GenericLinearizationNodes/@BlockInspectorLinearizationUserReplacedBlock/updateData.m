function updateData(this,J) 
% Update the block linearization

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $ $Date: 2009/05/23 08:21:38 $

ind_rep = strcmp(this.FullBlockName,{J.Mi.Replacements.Name});
this.SystemData = J.Mi.Replacements(ind_rep).Value;
if ~strcmp(this.InLinearizationPath,'N/A') && ~isempty(this.indy) && ~isempty(this.indu) && ...
        J.Mi.BlocksInPath(J.Mi.OutputInfo(this.indy(1),1)== J.Mi.BlockHandles);
    this.InLinearizationPath = 'Yes';
elseif ~strcmp(this.InLinearizationPath,'N/A')
    this.InLinearizationPath = 'No';
end
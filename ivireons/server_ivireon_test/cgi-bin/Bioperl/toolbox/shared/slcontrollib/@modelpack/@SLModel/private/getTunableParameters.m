function TunablePars = getTunableParameters(this)
% GETTUNABLEPARAMETERS Gets the list of tunable parameters in the model and
% the blocks that refer to them.
%
% Returns a struct array with fields Name, Type, ReferencedBy.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2010/03/31 18:38:26 $

model = this.Name;
utils = slcontrol.Utilities;

%Get top lvl model variables
TunablePars = utils.getTunableParameters(model);

%Get base workspace referenced variables for model references
mdlRef = utils.getNormalModeBlocks(model);
for ct = 1:numel(mdlRef)
   TP = utils.getTunableParameters(mdlRef{ct});
   idx = strcmp({TP.WorkspaceType},'base');
   TunablePars = horzcat(TunablePars,TP(idx));
end
end

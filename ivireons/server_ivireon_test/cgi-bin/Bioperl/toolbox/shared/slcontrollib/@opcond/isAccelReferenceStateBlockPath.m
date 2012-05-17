function isAccelerator = isAccelReferenceStateBlockPath(blockpath)
% ISACCELREFERENCESTATEBLOCKPATH Determine if a state block path is in an
% accelerated model reference.
 
% Author(s): John W. Glass 05-Nov-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/12/04 23:19:20 $

% Start at the top model reference and search until an accelerated
% block is hit or we run out of model references.
[mp,z,smp] = slprivate('decpath',blockpath,true);
isAccelerator = strcmp(get_param(mp,'SimulationMode'),'Accelerator');
while ~isAccelerator && ~isempty(smp)
    [mp,z,smp] = slprivate('decpath',smp,true);
    if ~isempty(smp)
        isAccelerator = strcmp(get_param(mp,'SimulationMode'),'Accelerator');
    end
end
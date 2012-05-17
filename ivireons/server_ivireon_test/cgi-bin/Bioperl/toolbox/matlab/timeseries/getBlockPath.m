function modelpath = getBlockPath(blockpath)
%
% tstool utility function
% GETBLOCKPATH  Get the block path relative to the model that it
% references.  For example the path:
%
% 'mdlref_ints_mod/Model3|mints_unit2/Model|mints_unit1/Integrator'
%
% Actually is
%
% 'mints_unit1/Integrator'
 
% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2007/03/21 00:54:56 $

%% Remove the first layer of model references if they are there
[modelpath,z,submodelpath]=slprivate('decpath',blockpath,true);

%%  Loop until each of the model reference paths have been taken away
while ~isempty(submodelpath)
    [modelpath,z,submodelpath] = slprivate('decpath',submodelpath,true);
end
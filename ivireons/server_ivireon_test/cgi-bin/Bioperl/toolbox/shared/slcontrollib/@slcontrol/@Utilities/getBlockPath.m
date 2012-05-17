function modelpath = getBlockPath(this,blockpath)
% GETBLOCKPATH  Get the block path relative to the model that it
% references.  For example the path:
%
% 'mdlref_ints_mod/Model3|mints_unit2/Model|mints_unit1/Integrator'
%
% Actually is
%
% 'mints_unit1/Integrator'
 
% Author(s): John W. Glass 04-Mar-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/03/21 00:57:16 $

%% Remove the first layer of model references if they are there
[modelpath,z,submodelpath]=slprivate('decpath',blockpath,true);

%%  Loop until each of the model reference paths have been taken away
while ~isempty(submodelpath)
    [modelpath,z,submodelpath]=slprivate('decpath',submodelpath,true);
end
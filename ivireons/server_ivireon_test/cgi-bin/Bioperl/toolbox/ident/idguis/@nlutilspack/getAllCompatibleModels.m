function M = getAllCompatibleModels(Type,NamesOnly,strict)
%Find all models in all model boards of a selected type whose dimension
%match those of the estimation data. If NamesOnly is true, only the model
%names are returned. If strict is true, the model I/O names must match
%those of the estimation data.
%
% Currently, this function is always called with strict=false.

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/11/17 13:32:22 $

if nargin<3
    strict = false;
end

if nargin<2
    NamesOnly = false;
end

Mall = nlutilspack.getAllModels(Type,false); %all models of chosen type
messenger = nlutilspack.getMessengerInstance('OldSITBGUI'); %singleton
ze = messenger.getCurrentEstimationData;
ny = size(ze,'ny');
nu = size(ze,'nu');

M = {};
for k = 1:length(Mall)
    thisM = Mall{k};
   if (isequal(ny,size(thisM,'ny')) && isequal(nu,size(thisM,'nu'))) && ...
           (~strict || (strict && isequal(messenger.getInputNames,thisM.uname) && ...
            isequal(messenger.getOutputNames,thisM.yname)))
        if NamesOnly
            thisM = thisM.Name;
        end
        M{end+1} = thisM;
   end
end

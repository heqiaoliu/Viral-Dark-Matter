function isInt = isParameterIntegrator(this,pID) 
% ISPARAMETERINTEGRATOR method to check whether parameter is an integrator
% or differentiator
%
% isInt = this.isParameterIntegrator(pID);
%
% Inputs:
%    pID - nx1 vector of STparameterID objects 
%
% Outputs:
%    isInt - nx1 vector of {-1,0,1} with 1 indicating an integrator, -1 a
%            differentiator
%
 
% Author(s): A. Stothert 10-Apr-2007
% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/09/15 20:47:06 $

TunedBlocks = this.Model.C;
isInt       = zeros(size(pID));
for ct = 1:numel(pID)
   Path = pID(ct).getPath;
   idx = strcmp(get(TunedBlocks,'Identifier'),Path);
   if any(idx)
      %Found tuned block with this parameter, now find correct parameter
      TB = TunedBlocks(idx);
      dt = TB.Ts > 0;    %Discrete time model
      ZPKSpecs = TunedBlocks(idx).getZPKParameterSpec;
      if ~isempty(ZPKSpecs.PZGroupSpec)
         %Check PZgroups for parameter
         allPSpec = ZPKSpecs.PZGroupSpec;
         allPID   = allPSpec.getID;
         if iscell(allPID), pID = [allPID{:}]; end
         idx = 1;
         found = false;
         while ~found && idx <= numel(allPID)
            found = pID(ct).isSame(allPID(idx));
            if ~found, idx = idx + 1; end
         end
         if found
            PZ = TB.PZGroup(idx);
            if isequal(PZ.getValue,dt)
               if isempty(PZ.Pole)
                  %Differentiator
                  isInt(ct) = -1;
               else
                  %Integrator
                  isInt(ct) = 1;
               end
            end
         end
      end
   end
end
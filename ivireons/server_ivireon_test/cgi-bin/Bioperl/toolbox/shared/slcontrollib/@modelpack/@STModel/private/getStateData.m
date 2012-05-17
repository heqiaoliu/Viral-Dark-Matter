function [Ts,Dim] = getStateData(this,Name,Path)
% GETSTATEDATA  private method to retrieve the state data from the SISOTOOL
% data object.
%
% Input:
%    Name - a string with the state name
%    Path - a string with the state path

% Author(s): A. Stothert 25-Jul-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2009/04/21 04:28:36 $

Ts  = [];
Dim = [];
if isempty(Path)
   Model = this.Model;
   %All SISOTOOL states are at the root level and so have empty paths, now
   %check whether we want the ClosedLoop, TunedLoop, or TunedBlock states.
   if strcmp(Model.Name,Name)
      %Is the closed loop
      Ts  = Model.Ts;
      sys = Model.getclosedloop;
      Dim = localGetStateDim(sys);
   end
   idx = strcmp(get(Model.L,'Identifier'),Name);
   if any(idx)
      %Is a tuned loop
      sys = Model.L(idx).getModel;
      Ts = sys.Ts;
      Dim = localGetStateDim(sys);
   end
   idx = strcmp(get(Model.C,'Identifier'),Name);
   if any(idx)
      %Is a tuned block
      sys = Model.C(idx).zpk;
      Ts  = sys.Ts;
      Dim = localGetStateDim(sys);
   end
end
end

function n = localGetStateDim(sys)
%Helper function to determine the state dimension of an lti object
if isa(sys,'ltipack.frddata')
   n = [0,1];
else
   n = [order(sys),1];
end
end

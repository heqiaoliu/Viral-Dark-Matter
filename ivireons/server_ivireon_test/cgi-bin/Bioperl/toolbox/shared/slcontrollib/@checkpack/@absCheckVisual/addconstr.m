function addconstr(this, Constr) 
% ADDCONSTR  interface method to add a bound to the visualization
%
% Used by the requirement viewer tool. The requirement tool calls this
% method from the new requirement dialog and the
% updateVisualizationBounds methods
%
% addconstr(this,Constr)
%
% Inputs:
%   Constr - either an srorequirement.requirement or editconstr.absEditor
%            subclass
%

% Author(s): A. Stothert 10-Feb-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/05/10 17:38:11 $

%Check input argument type
if isa(Constr, 'srorequirement.requirement')
   hReq = Constr;
elseif isa(Constr, 'editconstr.absEditor')
   %Add the new bound to the visualization plot
   hReq = Constr.Requirement;
else
   error('SLControllib:checkpack:errUnexpected', ...
      DAStudio.message('SLControllib:checkpack:errUnexpected', 'Wrong input type'))
end

%Construct the requirement visualization
hC = hReq.getView(this.hPlot);
this.hPlot.addconstr(hC,'NoInitialization') %Ensures requirement is registered with resppack.plot object

%Customize the requirement visualization
this.customizeConstr(hC)

%Add the bound to the requirement tool
hR = this.Application.getExtInst('Tools:Requirement Viewer');
hR.addBound(hC);
hR.isDirty = true;
end
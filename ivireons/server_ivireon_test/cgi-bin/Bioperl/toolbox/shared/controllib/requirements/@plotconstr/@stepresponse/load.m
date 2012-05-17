function load(this,SavedData) 
% LOAD  Enter a description here!
%
 
% Author(s): A. Stothert 04-Oct-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:33:59 $

if isfield(SavedData,'OpenEnd')
   this.setData('OpenEnd',SavedData.OpenEnd);
   SavedData = rmfield(SavedData,'OpenEnd');
end
if isfield(SavedData,'uID')
   this.setUID(SavedData.uID);
   SavedData = rmfield(SavedData,'uID');
end

%Set public properties
set(this,SavedData);

%Set step characteristics
xCoords = this.xCoords;
yCoords = this.yCoords;
this.StepChar.FinalValue   = yCoords(2,2)-0.5*(yCoords(2,2)-yCoords(5,2));
this.StepChar.InitialValue = 0;  %Revisit: SISOTOOL supporting affine systems
uF = this.StepChar.FinalValue;
u0 = this.StepChar.InitialValue;

%Set characteristics
this.StepChar.StepTime          = xCoords(1,1);
this.StepChar.RiseTime          = xCoords(4,1);
this.StepChar.SettlingTime      = xCoords(2,1);
this.StepChar.PercentOvershoot  = 100*(yCoords(1,1)-uF)/(uF-u0);
this.StepChar.PercentRise       = 100*(yCoords(4,1)-u0)/(uF-u0);
this.StepChar.PercentSettling   = 100*(yCoords(2,1)-uF)/(uF-u0);
this.StepChar.PercentUndershoot = 100*(u0-yCoords(3,1))/(uF-u0);
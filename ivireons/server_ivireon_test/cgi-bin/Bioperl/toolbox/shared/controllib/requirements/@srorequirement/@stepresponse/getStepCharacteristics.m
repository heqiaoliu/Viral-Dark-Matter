function varargout = getStepCharacteristics(this) 
% GETSTEPCHARACTERISTICS  return the step characteristics described by the
% response segment bounds stored in this requirement
%
 
% Author(s): A. Stothert 07-Jan-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:37:12 $

%Extract data points
xCoords = this.getData('xData');
yCoords = this.getData('yData');

uF = this.FinalValue;
u0 = this.InitialValue;

%Set characteristics
this.StepTime          = xCoords(1,1);
this.RiseTime          = xCoords(4,1);
this.SettlingTime      = xCoords(2,1);
this.PercentOvershoot  = 100*(yCoords(1,1)-uF)/(uF-u0);
this.PercentRise       = 100*(yCoords(4,1)-u0)/(uF-u0);
this.PercentSettling   = 100*(yCoords(2,1)-uF)/(uF-u0);
this.PercentUndershoot = 100*(u0-yCoords(3,1))/(uF-u0);

if nargout == 1
   varargout.InitialValue      = this.InitialValue;
   varargout.FinalValue        = this.FinalValue;
   varargout.StepTime          = this.StepTime;
   varargout.RiseTime          = this.RiseTime;
   varargout.SettlingTime      = this.SettlingTime;
   varargout.PercentRise       = this.PercentRise;
   varargout.PercentSettling   = this.PercentSettling;
   varargout.PercentOvershoot  = this.PercentOvershoot;
   varargout.PercentUndershoot = this.PercentUndershoot;
   varargout = {varargout};
end

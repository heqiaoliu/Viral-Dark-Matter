function Tdio = totaldelay(sys)
%TOTALDELAY  Computes total transport delay between inputs and outputs.
%
%   TD = TOTALDELAY(SYS) returns the total I/O delays TD for the LTI model 
%   SYS. The matrix TD combines the contribution from the "InputDelay", 
%   "OutputDelay", and "ioDelay" properties (type "help lti.InputDelay" 
%   for help on "InputDelay" and similarly for the other properties).
%
%   Delays are expressed in the unit specified by the "TimeUnit" property
%   for continuous-time models, and as integer multiples of the sampling 
%   period "Ts" for discrete-time models.
%
%   See also HASDELAY, DELAY2Z, LTI.

%   Author(s):  P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:52:20 $
s = size(sys);
ny = s(1);  nu = s(2);  ArraySize = [s(3:end) 1 1];
nsys = prod(ArraySize);
if nsys==0
   Tdio = zeros(ny,nu);
else
   Tdio = zeros([ny,nu,ArraySize]);
   isUniform = true;
   Data = sys.Data_;
   for ct=1:nsys
      D = Data(ct);
      iod = getIODelay(D);
      iod = iod + D.Delay.Input(:,ones(1,ny))' + D.Delay.Output(:,ones(1,nu));
      if hasInfNaN(iod)
         ctrlMsgUtils.error('Control:general:NotSupportedInternalDelays','totaldelay')
      end
      Tdio(:,:,ct) = iod;
      isUniform = isUniform && isequal(iod,Tdio(:,:,1));
   end
   if isUniform
      Tdio = Tdio(:,:,1);
   end
end

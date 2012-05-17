function c = eval(this,Sys)
% EVAL  Method to evaluate nicholspeak of a linear system
%
% Inputs:
%          this - a srorequirement.nicholspeak object.
%          Sys  - An LTI object.
% Outputs: 
%          c - a double giving the peak gain of the closed loop system 
%          formed by the input sys.
 
% Author(s): A. Stothert 31-May-2005
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:35:25 $

c = []; 
if isempty(Sys) 
   return 
end

if isa(Sys,'lti')
   Model = Sys;
else
   Model = Sys.Model;
end

%Form closed loop for each IO pair
[ny,nu] = size(Model);    %System size
c = nan(nu,ny);
for ct_u = 1:nu
   for ct_y = 1:ny
      clSys = feedback(Model(ct_u,ct_y),1,1,1,this.FeedbackSign);
      
      %Check if we can compute the norm for this closed loop system
      CanComputeNorm = true;
      if isa(clSys,'ss')
         %Check for internal delays
         iod = getIODelay(getPrivateData(clSys));
         if any(isnan(iod(:)))
            CanComputeNorm = false;
         end
      end
      
      if CanComputeNorm
         %Can compute inf norm of system
         c(ct_u,ct_y) = unitconv(norm(clSys,inf),'abs',this.getData('yunits'));
      else
         mag = nichols(clSys);
         c(ct_u,ct_y) = unitconv(max(mag(:)),'abs',this.getData('yunits'));
      end
      
   end
end


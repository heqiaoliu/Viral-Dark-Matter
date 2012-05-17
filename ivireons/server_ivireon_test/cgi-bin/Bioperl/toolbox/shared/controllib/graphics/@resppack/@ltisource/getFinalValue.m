function yf = getFinalValue(this,ModelIndex,RespInfo)
%GETFINALVALUE  Computes final value for step, impulse, or initial responses.

%   Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:21:17 $

% Default value = Inf (unstable)
Size = getsize(this);
yf = Inf(Size([1 2]));

% Compute final value
switch RespInfo.Type
   case 'step'
      Stable = isstable(this,ModelIndex);  % Note: will update DC gain value
      if Stable~=0
         % RE: Systems with delay dynamics are handled by this branch
         % (too expensive to compute poles even in discrete time)
         yf = this.Cache(ModelIndex).DCGain;
      end
      
   case 'impulse'
      [junk,StablePlusIntegrator] = isstable(this,ModelIndex);
      if StablePlusIntegrator~=0
         D = getModelData(this,ModelIndex);
         yf = getFinalValue(D,'impulse');
      end

   case 'initial'
      [junk,StablePlusIntegrator] = isstable(this,ModelIndex);
      if StablePlusIntegrator~=0 && isfield(RespInfo,'IC')
         D = getModelData(this,ModelIndex);
         yf = getFinalValue(D,'initial',RespInfo.IC);
      end
end

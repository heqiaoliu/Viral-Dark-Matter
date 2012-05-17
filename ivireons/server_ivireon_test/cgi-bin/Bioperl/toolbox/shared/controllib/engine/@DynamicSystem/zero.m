function [z,gain] = zero(sys,varargin)
%ZERO  Computes the transmission zeros of linear systems.
% 
%   Z = ZERO(SYS) returns the transmission zeros of the dynamic system SYS.
%
%   [Z,GAIN] = ZERO(SYS) also returns the transfer function gain
%   (in the zero-pole-gain sense) for SISO models SYS.
%   
%   [Z,...] = ZERO(SYS,J1,...,JN) computes the transmission zeros of the 
%   model with subscripts (J1,...,JN) in the model array SYS. 
%
%   See also DAMP, POLE, PZMAP, IOPZMAP, ZPK, LTI, DYNAMICSYSTEM.

%   Clay M. Thompson  7-23-90, 
%   Revised: P.Gahinet 5-15-96
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:37:15 $

% Size check
if nargout>1 && any(iosize(sys)>1),
   ctrlMsgUtils.error('Control:analysis:zero3')
end

try
   if nargin>1 || numsys(sys)==1
      [z,gain] = zero_(sys,varargin{:});
   else
      % Old syntax returning ND array padded with NaNs
      % REVISIT: turn off warning against internal delays in ssdata/zero
      s = size(sys);
      ArraySize = s(3:end);
      nzmax = 0;
      z = zeros([nzmax 1 ArraySize]);
      gain = zeros([1 1 ArraySize]);
      for ct=1:prod(ArraySize)
         [zsub,gain(1,1,ct)] = zero_(sys,ct);
         nz = length(zsub);
         if nz>nzmax
            z(nzmax+1:nz,:) = NaN;
            nzmax = nz;
         end
         z(1:nz,1,ct) = zsub;
         z(nz+1:nzmax,1,ct) = NaN;
      end
   end
catch E
   ltipack.throw(E,'command','zero',class(sys))
end

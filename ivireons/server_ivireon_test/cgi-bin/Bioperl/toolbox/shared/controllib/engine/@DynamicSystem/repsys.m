function sys = repsys(sys,s)
%REPSYS  Replicates dynamic systems.
%
%   RSYS = REPSYS(SYS,[M N]) replicates the dynamic system SYS into an 
%   M-by-N tiling pattern. The size of the resulting model RSYS is 
%   [size(SYS,1)*M, size(SYS,2)*N]. For example,
%      sys2 = repsys(sys,[2 3])
%   is equivalent to
%      sys2 = [sys sys sys ; sys sys sys] .
% 
%   RSYS = REPSYS(SYS,N) creates an N-by-N tiling. 
% 
%   RSYS = REPSYS(SYS,[M N S1 ... Sk]) replicates and tiles SYS along both 
%   I/O and array dimensions. The size of RSYS is 
%      [size(SYS,1)*M, size(SYS,2)*N, size(SYS,3)*S1, ...].
%
%   See also DYNAMICSYSTEM.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/22 04:19:24 $
error(nargchk(2,2,nargin))
% Validate S
if ~(isnumeric(s) && isreal(s) && isvector(s) && all(s==round(s)) && all(s>=0))
   ctrlMsgUtils.error('Control:ltiobject:repsys1');
elseif isscalar(s)
   s = [s s];
end
% Replicate data
try
   sys = repsys_(sys,s);
catch ME
   ltipack.throw(ME,'command','repsys',class(sys))
end
% Metadata
s = s(1:2);
if any(s~=1)
   sys.IOSize_ = sys.IOSize_ .* s;
   sys = resetMetaData(sys);
end

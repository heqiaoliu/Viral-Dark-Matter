function D = iorep(D,s,ios)
% Replicates model.
% 
%   D = IOREP(D,[M N]) replicates and tiles D along the I/O dimensions to 
%   produce the M-by-N model.
%
%   D = IOREP(D,[M N],[NY NU]) only replicates and tiles the first NY 
%   outputs and NU inputs.

%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:47:42 $
ni = nargin;
nfd = length(D.Delay.Internal);
if nfd==0 && ni<3
   D.b = repmat(D.b,[1 s(2)]);
   D.c = repmat(D.c,[s(1) 1]);
   D.d = repmat(D.d,s);
   D.Delay.Input = repmat(D.Delay.Input,[s(2) 1]);
   D.Delay.Output = repmat(D.Delay.Output,[s(1) 1]);
else
   sd = size(D.d);
   if ni<3
      ios = sd - nfd;
   end
   iy = [repmat(1:ios(1),[1 s(1)]) ios(1)+1:sd(1)];
   iu = [repmat(1:ios(2),[1 s(2)]) ios(2)+1:sd(2)];
   D.b = D.b(:,iu);
   D.c = D.c(iy,:);
   D.d = D.d(iy,iu);
   D.Delay.Input = D.Delay.Input(iu(1:end-nfd),:);
   D.Delay.Output = D.Delay.Output(iy(1:end-nfd),:);
end

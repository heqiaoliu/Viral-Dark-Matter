function D = iorep(D,s,ios)
% Replicates model.
%
%   D = IOREP(D,[M N]) replicates and tiles D along the I/O dimensions to
%   produce the M-by-N model.
%
%   D = IOREP(D,[M N],[NY NU]) only replicates and tiles the first NY
%   outputs and NU inputs.

%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:46:57 $
if nargin<3
   D.Response = repmat(D.Response,[s 1]);
   D.Delay.Input = repmat(D.Delay.Input,[s(2) 1]);
   D.Delay.Output = repmat(D.Delay.Output,[s(1) 1]);
   D.Delay.IO = repmat(D.Delay.IO,s);
else
   [ny,nu] = iosize(D);
   iy = [repmat(1:ios(1),[1 s(1)]) ios(1)+1:ny];
   iu = [repmat(1:ios(2),[1 s(2)]) ios(2)+1:nu];
   D.Response = D.Response(iy,iu,:);
   D.Delay.Input = D.Delay.Input(iu,:);
   D.Delay.Output = D.Delay.Output(iy,:);
   D.Delay.IO = D.Delay.IO(iy,iu);
end

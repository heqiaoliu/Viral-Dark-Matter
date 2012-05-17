function Dsub = getsubsys(D,rowIndex,colIndex)
% Extracts subsystem.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:40 $
% Delays
Delay = D.Delay;
Delay.Input = Delay.Input(colIndex,:);
Delay.Output = Delay.Output(rowIndex,:);
Delay.IO = Delay.IO(rowIndex,colIndex);

% Create subsystem
Dsub = ltipack.tfdata(D.num(rowIndex,colIndex),...
   D.den(rowIndex,colIndex),D.Ts);
Dsub.Delay = Delay;
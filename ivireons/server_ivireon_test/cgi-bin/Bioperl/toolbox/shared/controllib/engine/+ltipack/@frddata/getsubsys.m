function Dsub = getsubsys(D,rowIndex,colIndex,varargin)
% Extracts subsystem.

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:28 $
% Delays
Delay = D.Delay;
Delay.Input = Delay.Input(colIndex,:);
Delay.Output = Delay.Output(rowIndex,:);
Delay.IO = Delay.IO(rowIndex,colIndex);

% Create subsystem
Dsub = ltipack.frddata(D.Response(rowIndex,colIndex,:),...
   D.Frequency,D.Ts);
Dsub.FreqUnits = D.FreqUnits;
Dsub.Delay = Delay;
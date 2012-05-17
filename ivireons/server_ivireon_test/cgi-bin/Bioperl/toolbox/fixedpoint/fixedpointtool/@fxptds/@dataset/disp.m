function disp(h)
%DISP display method for dataset
%    DISP('fxptds.dataset containing 10 runs and 90 signals');

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/11/17 21:48:54 $

%we want to display the number of runs and total number of signals
[numRuns, numSignals] = h.getrecordcount;
disp(['fxptds.dataset containing ' num2str(numRuns) ' runs and ' num2str(numSignals) ' signals']);
s.SaveLocation = h.SaveLocation;
s.SaveVariable = h.SaveVariable;
s.isSaveOnClose = h.isSaveOnClose;
disp(s);

%[EOF]
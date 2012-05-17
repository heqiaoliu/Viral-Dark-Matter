function sim_open_sys(modelH)
%SIM_OPEN_SYS( MODELH )

%   Jay R. Torgerson
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.11.2.3 $  $Date: 2005/06/24 11:31:05 $


% This pause hack is no longer needed as the Model Explorer is not implemented in HG. 
% I'm commenting it out and leaving it here for posterity.  I'm not removing this file
% as it may prove useful in the future for Stateflow to have a gateway function to
% open_system() --experience tells me this is quite likely.  -jrt.
%
%pause(.001); % truly bizarr!  if you remove this line, simulink resizes the explorer!!!

open_system(modelH);

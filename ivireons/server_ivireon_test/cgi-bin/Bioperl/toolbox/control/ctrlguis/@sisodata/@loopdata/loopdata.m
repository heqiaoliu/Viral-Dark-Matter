function h = loopdata
% Constructor

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.20.4.2 $  $Date: 2005/12/22 17:40:17 $

% set unique identifier for loopdata used by model api
h = sisodata.loopdata;
h.Identifier = ['SISOTool ',datestr(now)];
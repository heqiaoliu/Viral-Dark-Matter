function GeneralInit(h)
%   GENERALINIT is the init method get called by RTW.makertw constructor.

%   Copyright 2002-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2008/04/14 19:41:48 $


% General initialization %
h.BuildDirectory     	      = '';
h.StartDirToRestore 	      = '';
h.GeneratedTLCSubDir   	      = '';
h.mexOpts                     = [];

% note: some properties are initialized in ParseBuildArgs.


%EOF

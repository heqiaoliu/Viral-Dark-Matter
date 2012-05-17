function h = MXArray(nm, ws)
    % MXArray  Class constructor function

    % Instantiate object
    h = DAStudio.MXArray;

    if nargin == 0
        error('DAStudio:MXArray:NameArgumentMissing', 'Name must be specified');
    elseif nargin == 1
        h.workspace = DAStudio.WorkspaceWrapper;
    else
        h.workspace = ws;
    end

    h.name = nm;


%   Copyright 2002-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/12/01 07:38:46 $

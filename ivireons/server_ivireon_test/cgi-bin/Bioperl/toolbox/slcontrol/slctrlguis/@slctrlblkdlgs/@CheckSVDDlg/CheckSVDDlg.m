function this = CheckSVDDlg(block) 

% Author(s): A. Stothert
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:55:40 $

% CHECKSVDDLG  constructor
%

this = slctrlblkdlgs.CheckSVDDlg(block);

%Initialize dialog properties based on block properties
this.initialize(handle(block))
end

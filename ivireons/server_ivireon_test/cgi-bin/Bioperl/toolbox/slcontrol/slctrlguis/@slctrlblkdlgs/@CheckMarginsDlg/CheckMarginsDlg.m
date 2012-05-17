function this = CheckMarginsDlg(block) 

% Author(s): A. Stothert
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:54:59 $

% CHECKMARGINSDLG  constructor
%

this = slctrlblkdlgs.CheckMarginsDlg(block);

%Initialize dialog properties based on block properties
this.initialize(handle(block))
end

function this = CheckBodeDlg(block) 

% Author(s): A. Stothert 06-Oct-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:54:33 $

% CHECKBODEDLG  constructor
%

this = slctrlblkdlgs.CheckBodeDlg(block);

%Initialize dialog properties based on block properties
this.initialize(handle(block))
end

function refresh(this,dlgSrc)
% refresh

%  Author(s): John Glass
%  Revised:
%   Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/04/21 04:50:26 $

dlgSrc.enableApplyButton(true);
dlgSrc.refresh();
dlgSrc.restoreFromSchema();
dlgSrc.resetSize(false);
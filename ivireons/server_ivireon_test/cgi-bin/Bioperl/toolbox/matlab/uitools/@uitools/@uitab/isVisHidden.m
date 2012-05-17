function res = isVisHidden(this)
%Helper method for uitab

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/20 16:45:35 $
res = ~(this.OKToModifyVis);

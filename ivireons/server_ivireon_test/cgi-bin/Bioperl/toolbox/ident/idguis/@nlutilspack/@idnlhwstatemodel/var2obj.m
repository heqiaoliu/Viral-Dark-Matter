function allpar = var2obj(this, x, option)
%VAR2OBJ Update state values and split them into separate columns

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:16:29 $

Ne = length(option.DataSize);
allpar = reshape(x,this.Data.Nx,Ne);

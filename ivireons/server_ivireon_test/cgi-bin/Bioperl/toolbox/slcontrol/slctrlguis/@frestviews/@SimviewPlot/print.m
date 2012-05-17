function print(this)
%PRINT  Print simView figure

% Author(s): Erman Korkut 26-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2009/04/21 04:49:53 $

layout(this);
set(this.Figure,'PaperPositionMode','auto');
printdlg(double(this.Figure));

end


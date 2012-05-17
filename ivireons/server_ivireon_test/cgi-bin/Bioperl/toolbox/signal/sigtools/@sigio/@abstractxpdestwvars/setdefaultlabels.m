function deflabels = setdefaultlabels(this, deflabels)
%SETDEFAULTLABELS   

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:27:27 $

this.privDefaultLabels = deflabels;

deflabels = [];

if isprop(this, 'ExportAs') & isdynpropenab(this,'ExportAs') & strcmpi(this.ExportAs,'Objects'),
    parse4obj(this);
else
    parse4vec(this);
end

% [EOF]

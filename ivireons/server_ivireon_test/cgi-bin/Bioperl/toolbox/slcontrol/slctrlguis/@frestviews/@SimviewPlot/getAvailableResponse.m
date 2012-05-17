function respind = getAvailableResponse(this)
%  GETAVAILABLERESPONSE returns the indice to an avaiable response for
%  reuse. It returns empty if there is none. This utility is used in
%  updateSelection to avoid creating new responses.
%
%

% Author(s): Erman Korkut 26-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2009/04/21 04:49:51 $

respind = [];
p = this.TimePlot;
for ct = 1:numel(p.Responses)
    if strcmp(p.Responses(ct).Visible,'off')
        respind = ct;
        break;
    end
end
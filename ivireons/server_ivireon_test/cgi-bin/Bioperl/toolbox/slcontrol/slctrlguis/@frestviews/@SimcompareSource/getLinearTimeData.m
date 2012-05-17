function getLinearTimeData(this,selection,resp,gridsize)
%  GETLINEARTIMEDATA obtains the data corresponding to the selection in the
%  linear output and places it in the data of the response.
%
%


% Author(s): Erman Korkut 23-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/04/21 04:49:44 $

% Wipe out all amplitudes to avoid assignment dimension mismatch
resp.Data.Amplitude = zeros(selection(2)-selection(1)+1,gridsize(1),gridsize(2));
% Write the data for all I/O pairs
for ctin = 1:gridsize(2)
    for ctout = 1:gridsize(1)
        resp.Data.Amplitude(:,ctout,ctin) = this.LinearOutput(selection(1):selection(2),ctout,ctin);
    end
end
% Write common time vector
resp.Data.Time = this.Output{1,1}.Time(selection(1):selection(2));
resp.Data.Ts = resp.Data.Time(2)-resp.Data.Time(1);
resp.Data.Focus = [resp.Data.Time(1) resp.Data.Time(end)];











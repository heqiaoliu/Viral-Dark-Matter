function getTimeData(this,selection,resp,gridsize)
%  GETTIMEDATA obtains the data corresponding to the selection and places
%  it in the data of the response.
%
%


% Author(s): Erman Korkut 12-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2009/04/21 04:49:59 $

% Handle empty selection for chirp case
if isempty(selection)
    resp.Data.Amplitude = zeros(0,gridsize(1),gridsize(2));
    resp.Data.Time = zeros(0,1);
    return;
end
% Wipe out all amplitudes to avoid assignment dimension mismatch
resp.Data.Amplitude = zeros(selection(2)-selection(1)+1,gridsize(1),gridsize(2));
% Write the data for all I/O pairs
for ctin = 1:gridsize(2)
    for ctout = 1:gridsize(1)
        resp.Data.Amplitude(:,ctout,ctin) = this.Output{ctout,ctin}.Data(...
            selection(1):selection(2));
    end
end
% Write common time vector
resp.Data.Time = this.Output{1,1}.Time(selection(1):selection(2));
resp.Data.Ts = resp.Data.Time(2)-resp.Data.Time(1);
resp.Data.Focus = [resp.Data.Time(1) resp.Data.Time(end)];











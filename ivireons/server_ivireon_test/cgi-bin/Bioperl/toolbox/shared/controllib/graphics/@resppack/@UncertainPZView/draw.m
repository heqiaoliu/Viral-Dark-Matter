function draw(this,Data,NormalRefresh)
%DRAW  Draws uncertain view

%   Author(s): Craig Buhr
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/05/10 17:37:29 $


[Ny, Nu] = size(this.UncertainPoleCurves);
RespData = Data.Data;
for ct = 1:Ny*Nu
    % Plot data as a line
    PoleData = [];
    ZeroData = [];
    for ct1 = 1:length(RespData)
        PoleData = [PoleData; RespData(ct1).Poles{:}];
        ZeroData = [ZeroData; RespData(ct1).Zeros{:}];
    end
end
set(double(this.UncertainPoleCurves),'XData',real(PoleData),'YData',imag(PoleData),'ZData',-2 * ones(size(PoleData)))
set(double(this.UncertainZeroCurves),'XData',real(ZeroData),'YData',imag(ZeroData),'ZData',-2 * ones(size(ZeroData)))
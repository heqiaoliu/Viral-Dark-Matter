function RespData = getUncertainPZData(this, r, Data, ioflag, PadeOrder)
% getUncertainPZData Updates pz data for uncertain models
%


%  Author(s): Craig Buhr
%  Copyright 1986-2010 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2010/05/10 17:37:37 $


if nargin < 4 || isempty(ioflag)
    ioflag = false;
else
    ioflag = true;
end

SysData = getUncertainModelData(this);
nsys = length(SysData);
% if numel(SysData)~=nsys
%    return  % number of models does not match number of data objects
% end

% Get new data from the @ltisource object.
if strcmp(r.View.Visible,'on')
    d = r.Data;
    RespData = Data.Data;
    if ioflag
        % Pole/zero map for individual I/O pairs
        for ct=1:nsys
            % Look for visible+cleared responses in response array
            if isfinite(SysData(ct)) 
                Dsys = SysData(ct);
                try %#ok<TRYNC>
                    if nargin == 5 && ~isempty(PadeOrder) && hasInternalDelay(Dsys)
                        Dsys = pade(Dsys,PadeOrder,PadeOrder,PadeOrder);
                    end
                    [RespData(ct).Zeros,RespData(ct).Poles] = iodynamics(Dsys);
                end
            end
        end
        
    else
        % Poles and transmission zeros
        for ct=1:nsys
            % Look for visible+cleared responses in response array
            if isfinite(SysData(ct))
                Dsys = SysData(ct);
                try %#ok<TRYNC>
                    if nargin == 4 && ~isempty(PadeOrder) && hasInternalDelay(Dsys)
                        Dsys = pade(Dsys,PadeOrder,PadeOrder,PadeOrder);
                    end
                    RespData(ct).Poles = {pole(Dsys)};
                    RespData(ct).Zeros = {zero(Dsys)};
                end
            end
        end
        
    end
    Data.Data = RespData;
end









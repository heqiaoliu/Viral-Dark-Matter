function pzmap(this,r,ioflag,PadeOrder)
%PZMAP   Updates Pole Zero Plots based on i/o flag. 
%        This is the  Data-Source implementation of pzmap.         

%  Author(s): Kamesh Subbarao
%   Copyright 1986-2009 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:21:32 $

if nargin < 3
    ioflag = false;
else
    % Revisit
    if isempty(ioflag)
        ioflag = false;
    else
        ioflag = true;
    end
end

nsys = length(r.Data);
SysData = getPrivateData(this.Model);
if numel(SysData)~=nsys
   return  % number of models does not match number of data objects
end

% Get new data from the @ltisource object.
if ioflag
   % Pole/zero map for individual I/O pairs
   for ct=1:nsys
      % Look for visible+cleared responses in response array
      if isempty(r.Data(ct).Poles) && ...
            strcmp(r.View(ct).Visible,'on') && isfinite(SysData(ct))
         Dsys = SysData(ct);
         d = r.Data(ct);
         try %#ok<TRYNC>
             if nargin == 4 && ~isempty(PadeOrder) && hasInternalDelay(Dsys)
                 Dsys = pade(Dsys,PadeOrder,PadeOrder,PadeOrder);
             end
            [d.Zeros,d.Poles] = iodynamics(Dsys);
            d.Ts = Dsys.Ts;
         end
      end
   end
   
else
   % Poles and transmission zeros
   for ct=1:nsys
      % Look for visible+cleared responses in response array
      if isempty(r.Data(ct).Poles) && ...
            strcmp(r.View(ct).Visible,'on') && isfinite(SysData(ct))
         Dsys = SysData(ct);
         d = r.Data(ct);
         try %#ok<TRYNC>
             if nargin == 4 && ~isempty(PadeOrder) && hasInternalDelay(Dsys)
                 Dsys = pade(Dsys,PadeOrder,PadeOrder,PadeOrder);
             end
            d.Poles = {pole(Dsys)};
            d.Zeros = {zero(Dsys)};
            d.Ts = Dsys.Ts;
         end
      end
   end
   
end

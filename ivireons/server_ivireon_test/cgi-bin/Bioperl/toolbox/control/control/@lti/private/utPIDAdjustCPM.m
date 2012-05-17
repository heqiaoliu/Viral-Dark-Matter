function val = utPIDAdjustCPM(CPM,BestCPM)
% Singular frequency based P/PI/PID/PIDF Tuning sub-routine

%   Author(s): Rong Chen
%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:31:12 $

% adjust BestCPM based on the longest settling time
Tfinal = max(BestCPM(:,3));
if isnan(Tfinal)
    val = inf;
else
    switch CPM
        case 'IAE'
            val = BestCPM(:,1)+abs(BestCPM(:,2)).*(Tfinal-BestCPM(:,3));            
        case 'ISE'
            val = BestCPM(:,1)+BestCPM(:,2).^2.*(Tfinal-BestCPM(:,3));                        
        case 'ITAE'
            val = BestCPM(:,1)+abs(BestCPM(:,2)).*(Tfinal.^2-BestCPM(:,3).^2)/2;                        
        case 'ITSE'
            val = BestCPM(:,1)+BestCPM(:,2).^2.*(Tfinal.^2-BestCPM(:,3).^2)/2;                        
    end
end

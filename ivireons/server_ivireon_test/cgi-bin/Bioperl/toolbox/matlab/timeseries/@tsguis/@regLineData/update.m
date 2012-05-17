function update(cd,r)
%UPDATE  Data update method for @regLineData class.

%  Author(s):  
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $  $Date: 2005/12/15 20:56:37 $

% Compute regression lines
for k=1:size(r.Data.XData,2)
    for j=1:size(r.Data.YData,2)
        I = find(~any(isnan([r.Data.XData(:,k) r.Data.YData(:,j)])')');
        if ~isempty(I)
            meanX = mean(r.Data.XData(I,k));
            meanY = mean(r.Data.YData(I,j));
            if norm(r.Data.XData(I,k)-meanX)>eps
                cd.Slopes(j,k) = (r.Data.YData(I,j)-meanY)'* ...
                    (r.Data.XData(I,k)-meanX)/norm(r.Data.XData(I,k)-meanX)^2;
                cd.Biases(j,k) = meanY-cd.Slopes(j,k)*meanX;
            else
                cd.Slopes(j,k) = NaN;
                cd.Biases(j,k) = NaN;
            end
        else
            cd.Slopes(j,k) = NaN;
            cd.Biases(j,k) = NaN;
        end    
    end
end

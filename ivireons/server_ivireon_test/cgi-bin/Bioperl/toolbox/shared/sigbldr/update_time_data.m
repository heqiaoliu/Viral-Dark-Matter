function [origX, origY] = update_time_data(curTmin, curTmax, newTmin, newTmax, origX, origY)
%UPDATE_TIME_DATA  updates the time range to new time range [newTmin newTmax] 
% and updates the associated displayed data and makes sure that the extreme
% points match the current time span. 

%  Copyright 2008-2010 The MathWorks, Inc.
%  $Revision: 1.1.6.1.2.1 $  $Date: 2010/06/17 14:13:23 $


% case1. curTmin < curTmax < newTmin < newTmax
% case2. curTmin < newTmin < curTmax < newTmax
% case6. newTmin < curTmin < curTmax < newTmax
if (newTmax ~= curTmax)
    if (newTmax > curTmax)                 
        if  (numel(origY) > 1) && (origY(end - 1) == origY(end))
            origX(end) = newTmax;          % If signal is piecewise const. 
        else                               % at curTmax, move the X value
            origX(end + 1) = newTmax;
            origY(end + 1) = origY(end);
        end
    elseif (newTmax <= curTmin)            % case4. newTmin < newTmax < curTmin < curTmax
        origX(end) = newTmax;
        origY(end) = origY(1);
        if origY(1) == origY(2)            % to match different references to origX down below based on origY value
            origX(2:end - 1) = [];
            origY(2:end - 1) = [];
        else
            origX(1:end - 1) = [];
            origY(1:end - 1) = [];
        end
    else                                   % case3. curTmin < newTmin < newTmax < curTmax
        newY = scalar_interp(newTmax, ...  % case5. newTmin < curTmin < newTmax < curTmax
            origX, origY, -1);    
        delIdx = (origX >= newTmax);
        origX(delIdx) = [];
        origY(delIdx) = [];
        origX = [origX newTmax];
        origY = [origY newY];
    end
end

% Adjusting the corresponding minimum values.
% case4. newTmin < newTmax < curTmin < curTmax
% case5. newTmin < curTmin < newTmax < curTmax
% case6. newTmin < curTmin < curTmax < newTmax
if (newTmin ~= curTmin)
    if (newTmin < curTmin)                 
        if  (numel(origY) > 1) && (origY(1) == origY(2))
            origX(1) = newTmin;
        else
            origX = [newTmin origX];
            origY = [origY(1) origY];
        end
    elseif (newTmin >= curTmax)            % case1. curTmin < curTmax < newTmin < newTmax
        origX(1) = newTmin;
        origY(1) = origY(end);
        origX(2:end - 1) = [];
        origY(2:end - 1) = [];
    else                                   % case3. curTmin < newTmin < newTmax < curTmax
        newY = scalar_interp(newTmin, ...  % case2. curTmin < newTmin < curTmax < newTmax
            origX, origY, 1);   
        delIdx = (origX <= newTmin);
        origX(delIdx) = []; 
        origY(delIdx) = [];
        origX = [ newTmin origX];
        origY = [newY origY];
    end
end
end %end function


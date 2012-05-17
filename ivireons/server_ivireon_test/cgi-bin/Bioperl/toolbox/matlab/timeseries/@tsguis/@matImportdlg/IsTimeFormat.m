function [flag, timeValue]=IsTimeFormat(h,rawdata)
% ISTIMEFORMAT check time format of a single cell

% input parameters should be in Cell Array format
% output:   between 0~31: standard MATLAB supported date/time format
%           -1: double values
%           NaN: string or other cases

% Author: Rong Chen 
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
flag=NaN;
timeValue=rawdata;
if ischar(rawdata)
    % a string
    try
        timeValue=datenum(rawdata);
        if timeValue==floor(timeValue)
            % date only
            flag=1;
        elseif isequal(rawdata,datestr(timeValue,13))
            % time only
            flag=13;
        elseif isequal(rawdata,datestr(timeValue,14))
            % time only
            flag=14;
        elseif isequal(rawdata,datestr(timeValue,15))
            % time only
            flag=15;
        elseif isequal(rawdata,datestr(timeValue,16))
            % time only
            flag=16;
        else
            % date+time
            flag=0;
        end
    catch
        ;
    end
elseif isnumeric(rawdata)
    flag=-1;
end


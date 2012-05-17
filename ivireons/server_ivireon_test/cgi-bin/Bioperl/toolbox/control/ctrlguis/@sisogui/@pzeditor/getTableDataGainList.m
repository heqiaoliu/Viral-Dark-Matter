function f = getTableDataGainList(Editor)
%GETTABLEDATAGAINLIST  get the current pure gain compensators and use them
%to create a java array which is sent to TableModel and refresh.  

%   Author(s): R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/04/30 00:36:55 $

import java.lang.* java.awt.*;

%% get handles
TableModel = Editor.Handles.ParaTabHandles.TableModel;
GainList = Editor.GainList;
PrecisionFormat = Editor.PrecisionFormat;

%% filter out tunable gains only
if ~isempty(GainList)
    len = length(GainList);
    tunableList = false(len,1);
    for ct=1:len
        % Unlike Gain blocks, Tunable field of the 'PID 1dof' block has multiple entries
        tunableList(ct) = any(strcmp({GainList(ct).Parameters.Tunable},'on'));
    end
    GainList = GainList(tunableList);
end

%% filter out double value parameters only
for ct = numel(GainList):-1:1
    if ~strcmp('double',class(GainList(ct).Gain))
        GainList(ct) = [];
    end
end

%% create a java array if there are tunable gains
% note: slider has to use integer, other fields are strings
numpara = length(GainList);
if numpara > 0
    % initialize a java array
    f = javaArray('java.lang.Object',numpara,5);
    % get current values from table (for comparison use only)
    javadata = TableModel.getData;
    % for each parameter, populate the corresponding row in the java array
    for ct = 1:numpara
        % column 1: name
        f(ct,1) = String(GainList(ct).Name);
        % column 2: double value (empty/scalar/non-scalar cases)
        if isempty(GainList(ct).Gain)
            f(ct,2) = String('');
        else
            if isscalar(GainList(ct).Gain)
                f(ct,2) = String(sprintf(PrecisionFormat,GainList(ct).Gain));
            else
                f(ct,2) = String(mat2str(GainList(ct).Gain,3));
            end
        end
        % column 3~5: min, slider, max values (non-empty scalar parameter only)
        if ~isempty(GainList(ct).Gain) && isscalar(GainList(ct).Gain)
            % get current min and max values from table whenever applicable
            if  ~isempty(javadata) && (Editor.idxC==Editor.idxCold)
                MinStrInTable = javadata(ct,3);
                MaxStrInTable = javadata(ct,5);
            else
                MinStrInTable = [];
                MaxStrInTable = [];
            end
            % update min and max values when (1) does not exist or (2) inf
            % or (3) current parameter value exceeds the range
            if (isempty(MinStrInTable) && isempty(MaxStrInTable)) ...
                || isinf(str2double(MinStrInTable)) || isinf(str2double(MaxStrInTable)) ...
                || (GainList(ct).Gain<str2double(MinStrInTable)) ...
                || (GainList(ct).Gain>str2double(MaxStrInTable))
                % update min and max based on the parameter value
                if GainList(ct).Gain>0
                    valMax = 10^(ceil(log10(GainList(ct).Gain)));
                    valMin = valMax/10;
                elseif GainList(ct).Gain<0
                    valMin = -10^(ceil(log10(abs(GainList(ct).Gain))));
                    valMax = valMin/10;
                else
                    valMin = -1;
                    valMax = 1;
                end
                MinValue = sprintf(PrecisionFormat,valMin);
                MaxValue = sprintf(PrecisionFormat,valMax);
                f(ct,3) = String(MinValue);
                f(ct,5) = String(MaxValue);
                % update slider based on the parameter value
                MaxMinDiff = str2double(MaxValue)-str2double(MinValue);
                if MaxMinDiff==0
                    f(ct,4) = Integer(500);
                else
                    f(ct,4) = Integer(1000.0/MaxMinDiff*(GainList(ct).Gain-str2double(MinValue)));
                end
            else
                % keep the original min and max
                f(ct,3) = String(MinStrInTable);
                f(ct,5) = String(MaxStrInTable);
                % update slider based on the parameter value
                MaxMinDiff = str2double(javadata(ct,5))-str2double(javadata(ct,3));
                if MaxMinDiff==0
                    f(ct,4) = Integer(500);
                else
                    f(ct,4) = Integer(1000.0/MaxMinDiff*(GainList(ct).Gain-str2double(javadata(ct,3))));
                end
            end
        % column 3~5: otherwise, disable those columns
        else
            f(ct,3) = String(sprintf(PrecisionFormat,1));
            f(ct,4) = Integer(0);
            f(ct,5) = String(sprintf(PrecisionFormat,-1));
        end
    end
    % update last visited compensator
    Editor.idxCold = Editor.idxC;
% if not tunable parameters, return empty
else
    f = [];
end

function f = getTableData(Editor)
%GETTABLEDATA  get the current compensator parameters from the object and
%use them to create a java array which is sent to TableModel and refresh. 

%   Author(s): R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2006/06/20 20:03:03 $

import java.lang.* java.awt.*;

%% get handles
TableModel = Editor.Handles.ParaTabHandles.TableModel;
Parameters = Editor.CompList(Editor.idxC).Parameters;
PrecisionFormat = Editor.PrecisionFormat;

%% filter out tunable parameters only
if ~isempty(Parameters)
    Parameters = Parameters(strcmp('on',{Parameters.Tunable}));
end

%% filter out double value parameters only
for ct = numel(Parameters):-1:1
    if ~strcmp('double',class(Parameters(ct).Value))
        Parameters(ct) = [];
    end
end

%% create a java array if there are tunable parameters
% note: slider has to use integer, other fields are strings
numpara = length(Parameters);
if numpara > 0
    % initialize a java array
    f = javaArray('java.lang.Object',numpara,5);
    % get current values from table (for comparison use only)
    javadata = TableModel.getData;
    % for each parameter, populate the corresponding row in the java array
    for ct = 1:numpara
        % column 1: name
        f(ct,1) = String(Parameters(ct).Name);
        % column 2: double value (empty/scalar/non-scalar cases)
        if isempty(Parameters(ct).Value)
            f(ct,2) = String('');
        else
            if isscalar(Parameters(ct).Value)
                f(ct,2) = String(sprintf(PrecisionFormat,Parameters(ct).Value));
            else
                f(ct,2) = String(mat2str(Parameters(ct).Value,3));
            end
        end
        % column 3~5: min, slider, max values (non-empty scalar parameter only)
        if ~isempty(Parameters(ct).Value) && isscalar(Parameters(ct).Value)
            % get current min and max values from table whenever applicable
            if ~isempty(javadata) && (Editor.idxC==Editor.idxCold)
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
                || (Parameters(ct).Value<str2double(MinStrInTable)) ...
                || (Parameters(ct).Value>str2double(MaxStrInTable))
                % update min and max based on the parameter value
                if Parameters(ct).Value>0
                    valMax = 10^(ceil(log10(Parameters(ct).Value)));
                    valMin = valMax/10;
                elseif Parameters(ct).Value<0
                    valMin = -10^(ceil(log10(abs(Parameters(ct).Value))));
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
                    f(ct,4) = Integer(1000.0/MaxMinDiff*(Parameters(ct).Value-str2double(MinValue)));
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
                    f(ct,4) = Integer(1000.0/MaxMinDiff*(Parameters(ct).Value-str2double(javadata(ct,3))));
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

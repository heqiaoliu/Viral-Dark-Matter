function [time, data] =  getaxesdata(h,s,path)
%GETAXESEDATA   Get the x/y data from struct or array.

%   Author(s): G. Taillefer
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/05/14 16:54:12 $

data = [];
if(isstruct(s))
    time = s.time;
    %scalars set time to 999 if format is StructureWithTime
    if(isequal(time, 999));time = [];	end
    %assign embedded.fi's to data
    if(numel(s.signals) == 1 && isa(s.signals.values, 'embedded.fi'))
        % Saving the data as a cell array to maintain data types of signals.
        data = {s.signals.values};
        if ndims(data{1}) > 2
          % Last dimension is time
          time = 0:size(data{1}.data,ndims(data{1})) - 1;
        else
          time = 0:numel(data{1}.data(:,1)) - 1;
        end
        return;
    end
    [rows, cols] = size(s.signals);
    %if scalar data is found assign the value(s) to data
    if(isequal(rows,1) && isequal(cols,1))
        % Saving the data as a cell array to maintain data types of signals.
        if isfield(s.signals,'blockName') && strcmpi(fxptds.getpath(s.signals.blockName),path) || isfield(s,'blockName') && strcmpi(fxptds.getpath(s.blockName),path)
            data = {s.signals.values};
        end
        return;
    end
    d = cell(1,cols);
    for sIdx = 1:cols
        % Saving the data as a cell array to maintain data types of signals.
        if isfield(s.signals,'blockName') && strcmpi(fxptds.getpath(s.signals.blockName),path) || isfield(s,'blockName') && strcmpi(fxptds.getpath(s.blockName),path)
           d{sIdx} = s.signals(sIdx).values;
        end
    end
    data = d;
else
    time = [];
    %let addsignals handle ND data
    if(ndims(s) > 2)
        % Saving the data as a cell array to maintain data types of signals.
        data = {s};
        return;
    end
    %otherwise deal with 2D special cases 1xM, Mx1, MxN
    [rows, cols] = size(s);
    %change 1xM to Mx1
    if(isequal(rows,1))
        % Saving the data as a cell array to maintain data types of signals.
        data = {s'};
        %return Mx1 as is
    elseif(cols == 1)
        % Saving the data as a cell array to maintain data types of signals.
        data = {s(:,1)};
        %get Mx1 time vector and Mx(N-1) data
    else
        if(isa(get_param(path,'Object'), 'Simulink.Scope')) 
            time = s(:,1);
            % Saving the data as a cell array to maintain data types of signals.
            data = {s(:,2:end)};
        else
            % Saving the data as a cell array to maintain data types of signals.
            data = {s};
        end
    end
end

% [EOF]

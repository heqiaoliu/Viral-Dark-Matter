function data2xp= formatexportdata(h)
%FORMATEXPORTDATA Utility used to call exportdata methods.

% This should be a private method

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2006/11/19 21:46:32 $

% Includes vectors and handle objects
data2xp = {};
data = cell(h.data);

% If Dynamic Property 'ExportAs' exists, can export either objects or arrays
if isprop(h, 'ExportAs') && isdynpropenab(h,'ExportAs'),
    if strcmpi(get(h,'ExportAs'),'Objects'),
        data2xp = data;
        for indx = 1:length(data2xp)
            data2xp{indx} = copy(data2xp{indx});
        end
    else
        % Call the object specific exporting methods
        for n = 1:length(data),
            newdata  = exportdata(data{n});
            data2xp =  {data2xp{:},newdata{:}};
        end
    end 
else
    % For the case of exporting arrays, call the built-in exporting method.
    data2xp = exportdata([data{:}]);
end

% [EOF]
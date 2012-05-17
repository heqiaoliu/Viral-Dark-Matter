function [checksum,saveDate] = get_checksum_from_dll(machineName,objectType,libraryName,chartFileNumber)
%   Copyright 1995-2009 The MathWorks, Inc.
% $Revision: 1.10.2.8 $

if(nargin<4)
    chartFileNumber = [];
end

if(nargin<3)
    libraryName = '';
end

if(nargin<2)
    objectType = '';
end

sfunctionName = [machineName,'_sfun'];
sfunctionFileName = [sfunctionName,'.', mexext];
saveDate = 0.0;

try
    args{1} = 'sf_get_check_sum';
    if(~isempty(objectType))
        args{end+1} = objectType;

        if ~isempty(libraryName)
            args{end+1} = libraryName;
        elseif ~isempty(chartFileNumber)
            args{end+1} = chartFileNumber;
        end
    end
    checksum = feval(sfunctionName,args{:});
    if(nargout>1)
        sfunctionDirInfo = dir(which(sfunctionFileName));            
        saveDate = sfunctionDirInfo.datenum;
    end
catch ME %#ok
    checksum = zeros(1,4);
    saveDate = 0.0;
end



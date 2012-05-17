function outpathstr = trimPath(h,ts)

% Copyright 2006 The MathWorks, Inc.

%% Find the full pathstr
tsnode = h.find('Timeseries',ts);
if isempty(tsnode)
    outpathstr = '';
    return;
end
pathstr = constructNodePath(tsnode);

%% Reduce the length of the pathstr to <maxL caharacters

maxL = 25;
outpathstr = pathstr;
% Identity map if length is < maxL
if length(pathstr)<maxL
    return
else
    pathsep = strfind(pathstr,'/');
    % If there are no path separators, return the lax maxL-3 characters
    % with a preceding ...
    if isempty(pathsep)
       outpathstr = sprintf('...%s',pathstr(length(pathstr)-maxL+3:end));
       return
    end
    % Remove chars up the first / ('Time Series/' or 
    % 'Simulink Time Series/', if the remaining string has length
    % < maxL-3 return the remaining path items with a preceding ...
    % Line X
    if length(pathstr)-pathsep(1)<=maxL-3
       outpathstr = sprintf('...%s',pathstr(pathsep(1)+1:end));
       return
    end
    % If there are no more path separators return the last maxL-3
    % characters with a preceding ...
    if length(pathsep)==1
        pathstr = pathstr(pathsep(1)+1:end);      
        outpathstr = sprintf('...%s',pathstr(length(pathstr)-maxL+3:end));
        return
    end
    % If there are >=2 path separators retain the root (Simulink signal
    % name)
    rootstr = pathstr(pathsep(1)+1:pathsep(2));
    pathstr = pathstr(pathsep(2)+1:end); 
    % Line X above =>length(pathstr)+length(rootstr)>maxL-3 but ...
    trailingLength = min(maxL-length(rootstr)-3,length(pathstr));
    if trailingLength<5 % Trailing string must be at least 5 chars long
        trailingLength = min(5,length(pathstr));
    end
    if trailingLength<length(pathstr)
        outpathstr = sprintf('...%s...%s',rootstr,...
            pathstr(length(pathstr)-trailingLength+1:end));
    else
         outpathstr = sprintf('...%s/%s',rootstr,...
            pathstr(length(pathstr)-trailingLength+1:end));
    end
end
    
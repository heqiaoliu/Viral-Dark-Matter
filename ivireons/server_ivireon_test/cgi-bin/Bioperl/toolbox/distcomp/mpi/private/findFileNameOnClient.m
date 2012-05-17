function [clientFullName err] = findFileNameOnClient(fullName)
;  %#ok undocumented
% Private function used by mpiprofview to find a file on the client when it
% is not in the same path as the file on the cluster.
% try to find the file name on the client by repeatedly calling which
% starting from 4 levels prior to the directory
err = '';
clientFullName = '';

if isempty(fullName)
    err = 'The cluster file path is empty.';
    return;
end

try
    a = textscan(fullName, '%s', 'delimiter', '/\\' );
    filePartName = a{1};
    for i = min(4, numel(filePartName)):-1:1
        if i~=1
            whichFileName = fullfile( filePartName{end-i+1:end} );
        else
            whichFileName = filePartName{end};
        end
        clientFullName = which(whichFileName);
        if ~isempty(clientFullName)
            break;
        end
    end
    if isempty(clientFullName)
        err = 'The file does not seem to exist on the client path.';
    end

catch
    % act as if nothing was found
    err = 'An error occurred while trying to find file.';
end
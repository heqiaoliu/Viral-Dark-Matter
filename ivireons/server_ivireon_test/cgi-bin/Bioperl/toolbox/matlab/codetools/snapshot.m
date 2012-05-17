function picName = snapshot(filename)
%SNAPSHOT	Run the M-file and save resulting picture.
%   SNAPSHOT(FILENAME)

% Copyright 1984-2008 The MathWorks, Inc. 
% $Revision: 1.1.6.6 $  $Date: 2008/06/24 17:11:30 $

% Argument parsing.
fullfilename = which(filename);
if isempty(fullfilename)
    error('MATLAB:snapshot:notfound','Can''t find "%s"',filename)
end
[pathstr,prefix] = fileparts(fullfilename);
baseImageName = fullfile(pathstr,'html',prefix);

% Make sure we can write out this file.
message = prepareOutputLocation([baseImageName '.png']);
if ~isempty(message)
    error('MATLAB:snapshot:CannotCreateImage',strrep(message,'\','\\'))
end

% Take the snapshot.
imHeight = 64;
imWidth = 85;
[pictureName,codeOutput,errorStatus] = ...
    takepicture(prefix,baseImageName,[],imHeight,imWidth,'print','png');
if errorStatus
    error(codeOutput)
end

% Return a cell array containg the picture name if there is one.
if nargout > 0
    picName = pictureName;
end

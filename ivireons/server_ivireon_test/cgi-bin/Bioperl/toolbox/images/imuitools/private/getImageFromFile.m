function [img,map] = getImageFromFile(filename,fcnName)
%getImageFromFile retrieves image from file

%   Copyright 2006-2009 The MathWorks, Inc.  
%   $Revision: 1.1.6.6 $  $Date: 2009/11/09 16:25:28 $

if ~ischar(filename)
    eid = sprintf('Images:%s:invalidType', fcnName);
    error(eid, 'The specified filename is not a string.');
end

if ~exist(filename, 'file')
  eid = sprintf('Images:%s:fileDoesNotExist', fcnName);
  error(eid, 'Cannot find the specified file: "%s"', filename);
end

wid = sprintf('Images:%s:multiframeFile', fcnName);

try
  img_info = [];
  img_info = imfinfo(filename);
  [img,map] = imread(filename);
  if numel(img_info) > 1
      warning(wid,'Can only display one frame from this multiframe file: %s.', filename);
  end
  
catch ME
        
    is_tif = ~isempty(img_info) && ...
            isfield(img_info(1),'Format') && ...
            strcmpi(img_info(1).Format,'tif');
        
    % Two different exceptions may be thrown as a result of an out of
    % memory state when reading a TIF file.
    % If rtifc fails in mxCreateNumericArray, MATLAB:nomem is thrown. If rtifc
    % fails in mxCreateUninitNumericArray, then MATLAB:pmaxsize is thrown.
    tif_out_of_memory = is_tif &&...
            ( strcmp(ME.identifier,'MATLAB:nomem') ||...
              strcmp(ME.identifier,'MATLAB:pmaxsize'));
    
    % suggest rsets if they ran out of memory with a tif file    
    if tif_out_of_memory

        outOfMemTifException = MException('Images:getImageFromFile:OutOfMemTif',...
                                          ['TIF too large to fit in memory.'...
                                          ' Create a reduced resolution dataset (R-Set)',...
                                          ' to view this image. Type "help rsetwrite"',...
                                          ' for more information.']);
        throw(outOfMemTifException);                              
    end
    
    if (isdicom(filename))
        
        img_info = dicominfo(filename);
        if isfield(img_info,'NumberOfFrames')
            [img,map] = dicomread(img_info,'Frames',1);
            warning(wid,'Can only display one frame from this multiframe file: %s.',filename);
        else
            [img,map] = dicomread(img_info);
        end
        
    elseif (isnitf(filename))

        [tf, eid, msg] = iptui.isNitfSupported(filename);
        if (~tf)
            eid = sprintf(eid, 'imtool');
            throw(MException(eid, msg));
        end
        
        img_info = nitfinfo(filename);
        img = nitfread(filename);
        map = [];
        
    else
        
        throw(MException('Images:getImageFromFile:unsupportedFormat', ...
                         'Unsupported file format.'));
        
    end

end    


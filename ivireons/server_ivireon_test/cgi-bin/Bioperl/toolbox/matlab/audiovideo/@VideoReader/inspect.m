function inspect(obj)
%INSPECT Open the inspector and inspect VideoReader object properties.
%
%    INSPECT(OBJ) opens the property inspector and allows you to
%    inspect and set properties for the VideoReader object, OBJ.
%
%    Example:
%        r = VideoReader('myfilename.avi');
%        inspect(r);

%    NCH DTL
%    Copyright 2004-2010 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2010/05/10 17:23:06 $

if ~isa(obj, 'VideoReader')
    error('MATLAB:VideoReader:noVideoReaderobj',...
          VideoReader.getError('MATLAB:VideoReader:noVideoReaderobj'));
end

if length(obj) > 1
    error('matlab:VideoReader:nonscalar', ...
        VideoReader.getError('matlab:VideoReader:nonscalar'));
end

% If called from Workspace Browser (openvar), error, so that the Variable
% Editor will be used. If called directly, warn, and bring up the Inspector.
stack = dbstack();
if any(strcmpi({stack.name}, 'openvar'))
    error('MATLAB:VideoReader:inspectObsolete',...
          VideoReader.getError('MATLAB:VideoReader:inspectObsolete'));
else
    warning('MATLAB:VideoReader:inspectObsolete',...
            VideoReader.getError('MATLAB:VideoReader:inspectObsolete'));
    inspect(obj.getImpl());
end

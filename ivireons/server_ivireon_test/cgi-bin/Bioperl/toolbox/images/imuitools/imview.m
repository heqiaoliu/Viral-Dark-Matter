function h = imview(varargin)
%IMVIEW Display image in the image viewer.
%   Note: This function is obsolete and may be removed in
%   future versions. Use IMTOOL instead.
%
%   The previous implementation of IMVIEW was in Java and due to a number
%   of limitations, we have replaced it by IMTOOL.
% 
%   See also IMSHOW, IMTOOL.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision $  $Date: 2004/08/10 01:49:21 $

wid = sprintf('Images:%s:obsoleteFunction',mfilename);
str1 = sprintf('%s is obsolete and may be removed in the future.',mfilename);
warning(wid,'%s\n%s',str1,'Calling IMTOOL instead.');

hh = imtool(varargin{:});

if (nargout > 0)
    % Only return handle if caller requested it.
    h = hh;
end


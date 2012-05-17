function c = horzcat(varargin)
%HORZCAT Horizontal concatenation of VideoReader objects.
%
%    See also VIDEOREADER/VERTCAT.

%    JCS DTL
%    Copyright 2004-2010 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2010/05/10 17:23:05 $

if (nargin == 1)
   c = varargin{1};
else
   error('MATLAB:VideoReader:nocatenation',...
         VideoReader.getError('MATLAB:VideoReader:nocatenation'));
end

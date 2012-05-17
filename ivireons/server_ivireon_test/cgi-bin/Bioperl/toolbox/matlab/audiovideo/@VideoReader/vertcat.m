function c = vertcat(varargin)
%VERTCAT Vertical concatenation of mmreader objects.

%    JCS DTL
%    Copyright 2004-2010 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2010/05/10 17:23:10 $

if (nargin == 1)
   c = varargin{1};
else
    error('MATLAB:VideoReader:nocatenation',...
          mmreader.getError('MATLAB:VideoReader:nocatenation'));
end

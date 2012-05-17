function wjpgc(varargin)
%WJPGC Write image data to a JPEG file.
%   WJPGC(IM,FILENAME) writes the grayscale or rgb
%   data in the uint8 array IM to the JPEG file specified
%   by the string FILENAME.
%
%   WJPGC(IM,FILENAME,QUALITY) uses the specified
%   quality factor.
%
%   See also IMWRITE, IMREAD, and IMFINFO.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/11/15 01:13:23 $
%#mex

error('MATLAB:wjpgc:missingMEX', 'Missing MEX-file WJPGC');

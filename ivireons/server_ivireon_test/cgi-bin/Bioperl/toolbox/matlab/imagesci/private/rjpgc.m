function varargout = rjpgc(varargin)
%RJPGC Read a JPEG image.
%   RJPGC is used to read image files in JPEG format.  Grayscale
%   and truecolor images can be read.
%
%   RGB = jpgread(filename)
%   RGB is a mxnx3 uint8 array containing the 24-bit image stored
%   in the jpeg file filename.    
%
%   GRAY = jpgread(filename)
%   GRAY is a mxn uint8 array containing the 8-bit grayscale
%   image stored in the jpeg file filename.    
%
%   See also WJPGC.

%   Chris Griffin 6-12-96
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/11/15 01:13:14 $
%#mex

error('MATLAB:rjpgc:missingMEX', 'Missing MEX-file RJPGC');


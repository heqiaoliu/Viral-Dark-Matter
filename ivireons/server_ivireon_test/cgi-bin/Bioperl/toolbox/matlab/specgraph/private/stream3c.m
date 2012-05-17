function varargout = stream3c(varargin)
%STREAM3C  Streamline from 2D and 3D vector data.
%   The calling syntax is:
%   verts = stream3c( x,y,z,    u,v,w,  sx,sy,sz, step, maxvert)
%   verts = stream3c( [],[],[], u,v,w,  sx,sy,sz, step, maxvert)
%   verts = stream3c( x,y,[],   u,v,[], sx,sy,[], step, maxvert)
%   verts = stream3c( [],[],[], u,v,[], sx,sy,[], step, maxvert)
%
%   See also STREAMLINE, STREAM3, STREAM2.

%   Copyright 1984-2007 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2007/10/15 22:55:09 $
%#mex

error('MATLAB:stream3c:MissingMexFile', ...
    'Missing MEX-file %s', upper(mfilename));






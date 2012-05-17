function ax = getaxes(h,varargin)
%GETAXES  Returns array of HG axes.
%
%   AX = GETAXES(H) returns an array of size H.SIZE containing
%   the HG axes associated with each data cell in the plot grid.
%
%   AX = GETAXES(H,'2d') formats AX as a 2D matrix.  This matrix
%   list the HG axes as they appear in the plot grid.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:15:28 $

if nargin==2
   ax = h.Axes2d;
else
   ax = h.Axes4d;
end
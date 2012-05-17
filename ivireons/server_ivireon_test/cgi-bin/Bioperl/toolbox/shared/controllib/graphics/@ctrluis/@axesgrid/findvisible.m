function [ax,indrow,indcol] = findvisible(h)
%FINDVISIBLE  Finds visible rows and columns in axes grid.
           
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:14:57 $

axgrid = h.Axes2d;
vis = reshape(strcmp(get(axgrid,'Visible'),'on'),size(axgrid));
indrow = find(any(vis,2));
indcol = find(any(vis,1))';
ax = axgrid(indrow,indcol);
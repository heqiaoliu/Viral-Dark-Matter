function refresh(h,varargin)
%REFRESH  Adjusts visibility of HG axes.
%
%   Invoked when modifying properties controlling axes visibility,
%   REFRESH updates the visibility of HG axes as well as the  
%   position and visibility of tick and text labels.  
%
%   This method interfaces with the @plotarray class by first updating
%   the visibility properties of the @plotarray objects, and then 
%   invoking @plotarray/refresh.

%   Author: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:15:59 $

h.Axes.Visible = strcmp(h.Visible,'on');
h.Axes.RowVisible = strcmp(h.RowVisible,'on');

% Update visibility of low-level HG axes
refresh(h.Axes)

% Set label and tick visibility
setlabels(h)
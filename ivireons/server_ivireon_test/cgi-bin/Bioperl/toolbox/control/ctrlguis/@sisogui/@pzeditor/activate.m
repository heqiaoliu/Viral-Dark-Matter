function activate(Editor,varargin)
%ACTIVATE  Activates PZ Editor.

%   Author(s): C. Buhr
%   Revised by R. Chen
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2005/12/22 17:42:49 $

% Turn editor from 'off' to 'idle', which will affect 'importdata' and
% 'show' functions
Editor.EditMode = 'idle';

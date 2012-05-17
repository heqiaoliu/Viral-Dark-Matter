function close(h,varargin)
%CLOSE  Hides dialog.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:09 $

awtinvoke(h.Handles.Frame,'setVisible(Z)',false);
h.Client = [];
h.Constraint = [];

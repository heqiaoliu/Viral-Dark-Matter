function h = hgloadStructClass(S)
%hgloadStructClass Convert a structure to object handles.
%
%  hgloadStructClass converts a saved structure into a set of new handles.
%  This function is called when MATLAB is using objects as HG handles.

%   Copyright 2009 The MathWorks, Inc.

% Create parent-less objects
h = struct2handle(S, 'none', 'convert');

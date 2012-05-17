function [d, isfull, type] = designmethods(this, varargin)
%DESIGNMETHODS   Return the design methods for this specification object.

%   Author(s): P. Costa
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/30 17:35:08 $

isfull = false;
type = 'fir';

d = {'multisection'};

% [EOF]

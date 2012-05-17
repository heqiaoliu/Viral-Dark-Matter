function  classname = superiorfloat(varargin)  %#ok<STOUT>
%SUPERIORFLOAT errors when superior input is neither single nor double.
  
%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2009/06/16 04:13:59 $

throwAsCaller( ...
    MException(...
        'MATLAB:datatypes:superiorfloat', ...
        'Inputs must be floats, namely single or double.'));

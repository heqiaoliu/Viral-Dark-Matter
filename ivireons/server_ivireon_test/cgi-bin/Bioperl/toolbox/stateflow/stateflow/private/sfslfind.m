function result = sfslfind(varargin)
%slfind(options)
%  Finds objects under Simulink's root object
%
%	Tom Walsh
%   Copyright 2001-2008 The MathWorks, Inc.
%   $Revision: 1.1.2.2 $  $Date: 2008/12/01 08:07:56 $

rt = slroot;
result = rt.find(varargin);

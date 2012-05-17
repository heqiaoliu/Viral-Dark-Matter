function clearFunction( varargin )
; %#ok Undocumented

% This function provides a clean workspace in which to call clear
% so that the call does not interfere with the base workspace, where
% clear classes and other such calls might end up affecting the 
% variables stored there.

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2009/11/07 20:52:10 $

clear( varargin{:} );
function uiload
% This function is undocumented and will change in a future release

%UILOAD Present file selection dialog and load result using LOAD
%
%   Example:
%       uiload %type in command line
%
% See also UIGETFILE UIPUTFILE OPEN UIIMPORT 

% Copyright 1984-2008 The MathWorks, Inc.
% $Revision: 1.37.4.2 $  $Date: 2008/06/24 17:15:20 $

evalin('caller','uiopen(''load'');');


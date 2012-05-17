function obj = goperror( exception )
; %#ok Undocumented
%GOPERROR Gop error marker object

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/06/24 17:07:58 $

if nargin == 0
    exception = MException('', '');
end

obj.Error = exception;
obj = class( obj, 'goperror' );

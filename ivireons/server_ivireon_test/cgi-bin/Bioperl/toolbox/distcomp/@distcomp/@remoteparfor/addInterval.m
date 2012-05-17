function OK = addInterval(obj, tag, varargin)
; %#ok Undocumented

%   Copyright 2007 The MathWorks, Inc.

%   $Revision: 1.1.6.2 $  $Date: 2007/11/09 19:51:12 $

OK = obj.ParforController.addInterval(tag, distcompMakeByteBufferHandle(distcompserialize(varargin)));








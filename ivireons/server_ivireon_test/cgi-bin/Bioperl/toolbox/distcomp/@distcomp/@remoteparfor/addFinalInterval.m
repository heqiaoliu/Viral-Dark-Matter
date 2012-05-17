function OK = addFinalInterval(obj, tag, varargin)
; %#ok Undocumented

%   Copyright 2007 The MathWorks, Inc.

%   $Revision: 1.1.6.2 $  $Date: 2007/11/09 19:51:11 $

OK = obj.ParforController.addFinalInterval(tag, distcompMakeByteBufferHandle(distcompserialize(varargin)));

function image = changeclass(class, varargin)
%CHANGECLASS will change the storage class of an image.
%   IMAGE = CHANGECLASS(CLASS,VARARGIN) will change the class of the input
%   arguments to CLASS. CLASS can be uint8, uint16, double, single, int16, or
%   logical.
%  
%   The output argument IMAGE will have the class CLASS. For example, in the
%   case of J = changeclass('uint8',X,'indexed'), J is im2uint8(X,'indexed').

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.8.4.3 $  $Date: 2004/08/10 01:44:32 $

switch class
 case 'uint8'
  image = im2uint8(varargin{:});
 case 'uint16'
  image = im2uint16(varargin{:});
 case 'double'
  image = im2double(varargin{:});
 case 'single'
  image = im2single(varargin{:});
 case 'int16'
  image = im2int16(varargin{1});
 case 'logical'
  image = varargin{1} ~= 0;
 otherwise
  eid = sprintf('Images:%s:unsupportedIPTClass',mfilename);                
  error(eid,'%s','Unsupported IPT data class.');
end

function m = datamode(q)
%DATAMODE Data type of a quantizer object
%   DATAMODE(Q) returns the datamode of quantizer object Q.  The data
%   mode of a quantizer object can be one of the strings:
%
%     double -  Double precision IEEE floating point.
%     fixed  -  Signed fixed-point in two's complement format.
%     float  -  Custom-precision floating-point.
%     none   -  No quantization is done.  Pass through input to output.
%     single -  Single precision IEEE floating point.
%     ufixed -  Unsigned fixed-point.
%
%   Example:
%     q = quantizer;
%     datamode(q)
%   returns the default 'fixed'.
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/GET, EMBEDDED.QUANTIZER/SET

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/12/20 07:13:24 $

m = get(q,'datamode');




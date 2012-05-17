function x = realmax(q)
%REALMAX Largest positive quantized number
%   REALMAX(Q) is the largest quantized number representable where Q is a
%   QUANTIZER object.  Anything larger overflows.
%
%   Examples:
%     q = quantizer('float',[32 8]);
%     realmax(q)
%   returns 3.4028e+038.
%
%     q = quantizer('fixed',[8 7]);
%     realmax(q)
%   returns 0.9921875.
%
%     q = quantizer('ufixed',[8 7]);
%     realmax(q)
%   returns 1.9921875.
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/EPS, 
%            EMBEDDED.QUANTIZER/REALMIN

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/12/20 07:14:14 $
x = q.realmax;



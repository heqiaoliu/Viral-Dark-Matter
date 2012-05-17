function [z,p,k] = zpk(this)
%ZPK  Discrete-time filter zero-pole-gain conversion.
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:45:21 $

[z,p,k] = tf2zpk(this.Numerator,this.Denominator);
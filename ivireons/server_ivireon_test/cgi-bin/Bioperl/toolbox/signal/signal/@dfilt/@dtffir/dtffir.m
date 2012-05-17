function varargout = dtffir(varargin)
%DTF Direct-form transfer function FIR filter virtual class.
%   DTFFIR is a virtual class---it is never intended to be instantiated.
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.3 $  $Date: 2007/12/14 15:08:31 $

msg = sprintf(['DTFFIR is not a filter structure.  Try one of\n',...
               'dfilt.dffir  (Direct-form FIR)\n',...
               'dfilt.dffirt (Direct-form FIR, transposed)\n',...
               'dfilt.dfasymfir (Antisymmetric FIR)\n',...
               'dfilt.dfsymfir     (Symmetric FIR).']);
error(generatemsgid('SigErr'),msg);

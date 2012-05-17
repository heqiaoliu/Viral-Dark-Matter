function varargout = dtfiir(varargin)
%DTFIIR Abstract class

%   Author: J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.3 $  $Date: 2007/12/14 15:08:32 $

msg = sprintf(['DTF is not a filter structure.  Try one of\n',...
               'dfilt.df1  (Direct-form I)\n',...
               'dfilt.df1t (Direct-form I, transposed)\n',...
               'dfilt.df2  (Direct-form II)\n',...
               'dfilt.df2t (Direct-form II, transposed).']);
error(generatemsgid('SigErr'),msg);

% [EOF]

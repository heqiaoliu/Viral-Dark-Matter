function logreport = getlogreport(this)
%GETLOGREPORT   Get the logreport.

%   Author(s): V. Pellissier
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2006/06/27 23:33:13 $

logreport = this.filterquantizer.loggingreport;
if isempty(logreport),
    w = warning('on');
    warning(generatemsgid('LoggingOff'), ...
        sprintf('\n%s\n%s\n%s', ....
    'To enable quantization reports, type: fipref(''LoggingMode'',''on'').', ...
        'Also, make sure the ''Arithmetic'' property is ''fixed'' and run the', ...
    'filter. Type <a href="matlab:help dfilt/qreport">help dfilt/qreport</a> for more information.'));
    warning(w);
else
    logreport = copy(logreport);
end

% [EOF]

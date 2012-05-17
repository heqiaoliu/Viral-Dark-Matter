function [params, values, descs, args] = abstract_genmcode(h, d)
%ABSTRACT_GENMCODE

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/10/04 18:13:02 $

[params, values, descs, args] = firceqrip_genmcode(h, d);

params = {params{:}, 'isincffactor', 'isincpower'};
values = {values{:}, getmcode(d, 'invsincfreqfactor'), getmcode(d, 'invsincpower')};
descs  = {descs{:}, 'Inverse Sinc Frequency Factor', 'Inverse Sinc Power'};

args = sprintf('%s, ''invsinc'', isincffactor, isincpower', args);

% [EOF]

function disp(h)
% DISP Display method for the FTP object.

% Matthew J. Simoneau, 14-Nov-2001
% Copyright 1984-2008 The MathWorks, Inc.
% $Revision: 1.1.4.2 $  $Date: 2008/06/24 17:13:43 $

if length(h) ~= 1
    % FTP array; Should work for empty case as well.
    s = size(h);
    str = sprintf('%dx',s);
    str(end) = [];
    fprintf('%s array of FTP objects\n', str);
else
    disp(sprintf( ...
        '  FTP Object\n     host: %s\n     user: %s\n      dir: %s\n     mode: %s', ...
        h.host,h.username,char(h.remotePwd.toString),char(h.type.toString)));
end
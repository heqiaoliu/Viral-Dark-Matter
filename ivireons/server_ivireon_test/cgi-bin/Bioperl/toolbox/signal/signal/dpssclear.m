function dpssclear(N,NW)
%DPSSCLEAR  Remove discrete prolate spheroidal sequences from database.
%   DPSSCLEAR(N,NW) removes the DPSSs with length N and time-halfbandwidth 
%   product NW, from the DPSS MAT-file database, 'dpss.mat'.  
%
%   See also DPSS, DPSSSAVE, DPSSLOAD, DPSSDIR.

%   Author: T. Krauss
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.3 $

error(nargchk(2,2,nargin,'struct'))
index = dpssdir;

if ~isempty(index)
    w = which('dpss.mat');

    i = find([index.N] == N);
    if isempty(i)
        error(generatemsgid('SignalErr'),'No DPSSs in the database of given length.')
    end
    j = find([index(i).wlist.NW] == NW);
    if isempty(j)
        error(generatemsgid('SignalErr'),'No DPSSs in the database of given length with NW = %g.',NW)
    end

    key = index(i).wlist(j).key;
    index(i).wlist(j) = [];
    if isempty(index(i).wlist)
        index(i) = [];
    end

    str = sprintf('E%g = []; V%g = [];',key,key);
    eval(str)
    save(w, sprintf('E%g', key), sprintf('V%g', key), 'index', '-append');
end

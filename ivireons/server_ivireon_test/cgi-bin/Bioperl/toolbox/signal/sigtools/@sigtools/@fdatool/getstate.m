function s = getstate(hFDA)
%GETSTATE Returns the state of FDATool.
%   S = GETSTATE(hFDA) returns the state structure for the session of
%   FDATOOL associated with hFDA.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.20.4.5 $ $Date: 2007/12/14 15:21:12 $

error(nargchk(1,1,nargin,'struct'));

hComps = allchild(hFDA);

s = [];

for indx = 1:length(hComps)

    if ismethod(hComps(indx), 'getstate')
        
        lbl = get(hComps(indx).classhandle, 'name');
        sc = getstate(hComps(indx));
        if ~isempty(sc)
            s.(lbl) = sc;
        end
    end
end

s.current_filt = getfilter(hFDA);

% For backwards compatibility purposes, we place the
% filtermadeby in the mode field
s.filterMadeBy = get(hFDA,'filterMadeBy');
s.currentFs    = get(getfilter(hFDA, 'wfs'), 'Fs');
s.currentName  = get(getfilter(hFDA, 'wfs'), 'Name');
s.version      = get(hFDA,'version');
s.mcode        = copy(get(hFDA, 'MCode'));

% [EOF]

function filtobj = getfilter(hFDA, wfs)
%GETFILTER Returns the current filter of FDATool.
%   FILT = GETFILTER(hFDA) returns the current filter object of the FDATool
%   session specified by hFDA.  The filter object must be a DFILT.
%
% See also SETFILTER.

%   Author(s): P. Pacheco, V. Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.8 $  $Date: 2009/07/27 20:32:22 $

error(nargchk(1,2,nargin,'struct'));

filtobj = get(hFDA, 'Filter');

if isempty(filtobj),
    [filtobj,opts.mcode] = defaultfilter(hFDA);
    opts.update    = true;
    opts.fs        = 48000;
    opts.default   = false;
    opts.source    = 'Designed';
    opts.name      = xlate('Lowpass Equiripple');
    opts.filedirty = false;
    setfilter(hFDA, filtobj, opts);
    filtobj = get(hFDA, 'Filter');
end

if nargin < 2,
    filtobj = get(filtobj, 'Filter');
end
    
% [EOF]


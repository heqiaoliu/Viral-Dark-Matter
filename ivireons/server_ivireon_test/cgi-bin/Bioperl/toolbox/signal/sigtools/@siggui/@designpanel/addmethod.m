function addmethod(h, filtertype, resptype, method, constructor, typename)
%ADDMETHOD Add a design method to the design panel
%   ADDMETHOD(H, FILTERTYPE, RESPTYPE, METHODNAME, METHODTAG)
%
%   ADDMETHOD(H, FILTERTYPE, RESPTYPE, METHODNAME, METHODTAG, TYPENAME)


%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.3 $  $Date: 2004/04/13 00:22:21 $

dinfo.name = method;
dinfo.tag  = constructor;

at = get(h, 'AvailableTypes');

if ~iscell(filtertype{1}), filtertype = {filtertype}; end

for i = 1:length(filtertype)
    indx = find(strcmp({at.(filtertype{i}{1}).tag}, filtertype{i}{2}));
    if isempty(indx),
        ninfo.name       = typename;
        ninfo.tag        = filtertype{i}{2};
        ninfo.fir        = [];
        ninfo.iir        = [];
        ninfo.(resptype) = dinfo;
        at.(filtertype{i}{1})(end+1) = ninfo;
    else
        if isempty(at.(filtertype{i}{1})(indx).(resptype)),
            at.(filtertype{i}{1})(indx).(resptype)        = dinfo;
        else
            at.(filtertype{i}{1})(indx).(resptype)(end+1) = dinfo;
        end
    end
end

set(h, 'AvailableTypes', at);

% [EOF]

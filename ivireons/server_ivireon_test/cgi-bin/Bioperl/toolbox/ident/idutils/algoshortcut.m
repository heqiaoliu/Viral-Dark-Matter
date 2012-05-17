function [fnames, fvalues, pvlist] = algoshortcut(pvlist)
%ALGOSHORTCUT: Algorithm properties shortcut handling
%
%  [fnames, fvalues, pvlist] = algoshortcut(pvlist)
%
%  pvlist: cell array of PV-pairs possibly containing Algorithm fields
%  which are erased in the output argument.
%
%  fnames, fvalues: Algorithm field names and properties found in pvlist.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:51:09 $

% Author(s): Qinghua Zhang

shortcutlist = bbalgodef;
shortcutlist = rmfield(shortcutlist, 'Advanced');
shortcutlist = fields(shortcutlist);

nsh = length(shortcutlist);
ind = zeros(nsh,2);
fpnames = cell(nsh,1);
fvalues = cell(nsh,1);
pt = 0;
for kp=1:2:numel(pvlist)
    if length(pvlist{kp})<2
        continue % Do not process strings shorter than 2 characters
    end
    if strncmpi(pvlist{kp},'trace',length(pvlist{kp}))
        pvlist{kp} = 'Display';
        ctrlMsgUtils.warning('Ident:idmodel:obsoletePropTrace')
    end
    [value, msg] = strchoice(shortcutlist, pvlist{kp}, '');
    if isempty(msg)
        pt = pt + 1;
        ind(pt,:) = [kp kp+1];
        fpnames{pt} = value;
        fvalues{pt} = pvlist{kp+1};
    end
end
if pt
    ind = ind(1:pt,:); % Remove non used rows
    fnames = fpnames(1:pt);
    fvalues = fvalues(1:pt);
    pvlist(ind(:)) = []; % Remove short-hands from argument list
else
    fnames = {};
    fvalues = {};
end

% FILE END
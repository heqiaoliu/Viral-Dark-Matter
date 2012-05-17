function undo(h)
%UNDO  Undo transaction.
% Tsc is a handle to the tscollection object on which the undo operation
% needs to apply.

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2005/05/27 14:14:52 $

tslist = h.TimeseriesCell;
Tsc = h.TscollectionHandle;

if isempty(Tsc) || ~isa(Tsc,'tsdata.tscollection')
    display('tscollection is invalid.')
    return;
end

if ~isempty(tslist)
    if h.WasRemoved
        % members were removed
        %   Note: We do not want to make a copy of the timeseries, but
        %   use the original handle when restoring a timeseries member.
        %   This is achieved by an additonal argument:
        %   'TSTOOL_COPY_BY_REFERENCE'
        for k = 1:length(tslist)
            Tsc.addts(tslist{k},'TSTOOL_COPY_BY_REFERENCE');
        end
    else
        % new members were added 
        for k = 1:length(tslist)
            Tsc.removets(tslist{k}.Name);
        end
    end
end



function chname = idchnona(Names)
%IDCHNONA Checks for forbidden channel names
%
%   CHNAME = IDCHNONA(Name) returns empty if Name is an allowed channel
%   name. Otherwise CHNAME is a forbidden name. The check is made
%   for case-insensitive names.
 
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.2.3 $ $Date: 2010/04/21 21:26:11 $

chname = [];
if ~iscell(Names),Names={Names};end

PropList = {'measured','noise'};

% Set number of characters used for name comparison
for kk = 1:length(Names)
    Name = Names{kk};
    if strcmpi(Name,'all')
        ctrlMsgUtils.error('Ident:general:ALLAsChannelName',Name)
    end
    nchars = length(Name);

    if nchars
        imatch = find(strncmpi(Name,PropList,nchars));
        if ~isempty(imatch)
            chname = PropList{imatch};
        end
    end
    
end


 
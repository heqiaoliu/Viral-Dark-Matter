function	varargout = cv_dialog_options(varargin)

     
%   Bill Aldrich
%   Copyright 1990-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $



	% Table of coverage options that are visible to users.  This function
	% is the main gateway to turn metrics on and off. Each entry
	% has the form:
	%
	% 'UI name', ...
	% 'single letter abbr.', ...
	% 'set true command', ...
	% 'set false command', ...
	% 'default value'
	
	optionsTable = { ...
        DAStudio.message('Slvnv:simcoverage:logicBlkShortcircuit'), ... 
	    's', ...
	    0,...
        'logicBlkShortcircuit'; ...
        DAStudio.message('Slvnv:simcoverage:checkUnsupportedBlocks'), ... 
	    'w', ...
	    1,...
        'checkUnsupportedBlocks'; ...
        DAStudio.message('Slvnv:simcoverage:forceBlockReductionOff'), ... 
	    'f', ...
	    1,...
        'forceBlockReductionOff'...
	    };
% Switch yard to determine the use scenario

switch(nargin),
case 0
    varargout{1} = optionsTable;
case 2
    switch(varargin{1})
    case 'enabledTags'
        settingStr = varargin{2};
        varargout{1} = abbrev_to_index(settingStr, optionsTable);
        if nargout > 1
            varargout{2} = optionsTable(Ind,:);
        end
    end
end

function options = abbrev_to_index(abbrev,optionsTable)
    [r ~] = size(optionsTable);
    options = cell(r,3);
    for j = 1:r
        options{j,1} = optionsTable{j,2};
        options{j,2} = ~isempty(findstr(abbrev, optionsTable{j,2}));
        options{j,3} = optionsTable{j,4};
    end
    




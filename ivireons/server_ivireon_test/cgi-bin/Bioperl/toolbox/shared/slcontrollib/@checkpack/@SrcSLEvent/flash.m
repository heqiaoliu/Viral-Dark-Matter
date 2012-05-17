function flash(this, ~, ~)
%FLASH   Alternate highlighting of block connected to SLEvent source

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/26 17:50:56 $


blockpath = getFullName(get(this,'BlockHandle'));
[blockpath,~,submodelpath]=slprivate('decpath',blockpath,true);
% Loop until each of the model reference paths have been taken away
while ~isempty(submodelpath)
    [blockpath,~,submodelpath]=slprivate('decpath',submodelpath,true);
end

% Highlight the block
hilite_system(blockpath,'find');
end


function createRespData(this)
%CREATERESPDATA Creates response data for response config table 

%   Author(s): C. Buhr
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2007/08/20 16:25:25 $

% Get list of Loopviews (i.e. response selection list)
LoopView = this.SISODB.LoopData.LoopView;
NumLV = length(LoopView);

% Get LoopView descriptions for table list
RespNames = get(LoopView,{'Description'});

% Add space in front of label so selection highlight does not cover first
% letter
% Revisit: when uitable becomes more flexible
for cnt = 1:length(RespNames)
    RespNames{cnt} = [RespNames{cnt}];
end

% Generate booleen matrix for selected responses
boolData = mat2cell(false(NumLV,7),ones(NumLV,1),ones(7,1));
this.RespData = [boolData, RespNames];
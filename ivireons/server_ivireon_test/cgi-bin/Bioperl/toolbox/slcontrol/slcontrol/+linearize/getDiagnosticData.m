function [DiagnosticMessages,BlocksInPathByName] = getDiagnosticData(J)
% GETDIAGNOSTICDATA  Create diagnostic information data structure.
 
% Author(s): John W. Glass 10-Mar-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/04/11 20:40:34 $

% Get the block handles and the other information such as sample time.
BlockHandles = J(1).Mi.BlockHandles;
BlockNameList = cell(size(J(1).Mi.BlockHandles));

% Find the hidden buffers and remove carriage
for ct = 1:length(BlockNameList)
    b = get_param(J(1).Mi.BlockHandles(ct),'Object');
    if b.isSynthesized
        BlockHandles(ct) = 0;
    else
        BlockNameList{ct} = regexprep(getfullname(BlockHandles(ct)),'\n',' ');
    end
end
SynthesizedBlocks = (BlockHandles == 0);
BlockHandles(SynthesizedBlocks) = [];
BlockNameList(SynthesizedBlocks) = [];

% Store the diagnostic data
DiagnosticMessages = cell(numel(J),1);
BlocksInPathByName = cell(numel(J),1);
for ct = 1:numel(J)
    BlocksInPath = J(ct).Mi.BlocksInPath;
    BlockAnalyticFlags = J(ct).Mi.BlockAnalyticFlags;    
    % Remove references to synthesized blocks    
    BlocksInPath(SynthesizedBlocks) = [];
    BlockAnalyticFlags(SynthesizedBlocks) = [];
    
    DiagnosticMessages{ct} = struct('BlockName',getfullname(BlockHandles),...
        'BlockType',get_param(BlockHandles,'BlockType'),...
        'InPath',[], 'Type',[],'Message',[]);
    
    for ct2 = 1:numel(BlockHandles)
        DiagnosticMessages{ct}(ct2).InPath = BlocksInPath(ct2);
        DiagnosticMessages{ct}(ct2).Type = BlockAnalyticFlags(ct2).jacobian.type;
        DiagnosticMessages{ct}(ct2).Message = BlockAnalyticFlags(ct2).jacobian.message;
    end
    
    % Store the stripped down list of blocks that are in the path
    BlocksInPathByName{ct} = BlockNameList(BlocksInPath);
end
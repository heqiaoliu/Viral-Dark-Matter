function simUtil_addLines(sys,outblocks,outports,inblocks,inports)
%SIMUTIL_ADDLINES  Shortcut function to add lines
%
% Example
%
%   simUtil_addLines('mysys',  ...
%       {   'inport1' 'inport2'  'inport3'  'inport4'  } , ...
%       ones(1,4) , ...
%       {  'muxin'  'muxin'  'muxin' 'gain' }, ...
%       [1:4] );
%   

%   Copyright 2002-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $
%   $Date: 2009/09/28 20:33:03 $

for i=1:length(outblocks)
    outport = [  outblocks{i} '/' int2str(outports(i)) ];
    inport  = [  inblocks{i} '/' int2str(inports(i)) ];
    add_line(sys,outport,inport,'autorouting','on');
end




function setTunedLFT(this,IC,Blocks)
% setTunedLFT Sets the IC matrix and TunedBlocks of the TunedLFT and makes 
% sure structure has proper fields 
 
%	Copyright 2006-2010 The MathWorks, Inc. 
%	$Revision: 1.1.8.3 $  $Date: 2010/03/26 17:22:11 $

tmp = cell(length(IC),1);

this.TunedLFT = struct(...
    'IC', IC, ...
    'Blocks', Blocks, ...
    'SSData', {tmp}, ...
    'ZPKData', {tmp}, ...
    'FRDData', {tmp});

this.ModelData = tmp;

this.ContainsDelay = [];
this.ContainsFRD=[];
this.TunedLFTSSData = tmp;
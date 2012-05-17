function addtip(this,tipfcn)
%ADDTIP  Adds a line tip to g-objects in dataview.
 
%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:28:56 $

if nargin==1
   % Default tip function (calls MAKETIP first on data source, then on view)
   tipfcn = @LocalTipFcn;
end

wf = findcarrier(this);  % @waveform carrier
for ct = 1:length(this.View)
   info = struct(...
      'Data',this.Data(ct),...
      'View',this.View(ct),...
      'Carrier',wf,...
      'Tip',[],...
      'TipOptions',{{}},...
      'Row',[],...
      'Col',[],...
      'ArrayIndex',ct);
   this.View(ct).addtip(tipfcn,info);
end


% ----------------------------------------------------------------------------%
% Purpose: Build tip text for dataview's
% ----------------------------------------------------------------------------%
function TipText = LocalTipFcn(DataTip,CursorInfo,info)
TipText = '';
% First try evaluating the data source's MAKETIP method
DataSrc = info.Carrier.DataSrc;
if ~isempty(DataSrc)
   try 
      TipText = maketip(DataSrc,DataTip,info);
   end
end
% Otherwise use built-in tip for View object
if isempty(TipText)
   try 
      TipText = maketip(info.View,DataTip,info);
   end
end

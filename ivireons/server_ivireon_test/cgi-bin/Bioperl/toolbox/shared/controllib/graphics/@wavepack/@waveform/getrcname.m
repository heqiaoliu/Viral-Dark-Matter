function [RowNames,ColNames] = getrcname(this)
%GETRCNAME  Accesses waveform's row and column names (relative to axes grid).

%  Author(s): Pascal Gahinet
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:27:55 $

% Get row/column labels of @waveplot (returns {} when names not relevant)
[PlotRowLabels,PlotColLabels] = getrcname(this.Parent);

% Get row/column labels from data source
if ~isempty(this.DataSrc)
   [SrcRowLabels,SrcColLabels] = getrcname(this.DataSrc);
else
   SrcRowLabels = {};
   SrcColLabels = {};
end

% Reconcile names
RowNames = LocalGetName(PlotRowLabels,SrcRowLabels,this.RowIndex);
ColNames = LocalGetName(PlotColLabels,SrcColLabels,this.ColumnIndex);

%--------------------- Local Functions -----------------------

function Names = LocalGetName(Names,SrcNames,Index)
% Determine i/o names as function of data source and plot
if ~isempty(Names)
   % i/o names are meaningfull
   Names = Names(Index);
   % Finalize names
   if ~isempty(SrcNames) && isa(SrcNames,'cell')
      % Use source names when available
      idx = find(cellfun('length',SrcNames)>0);
      Names(idx) = SrcNames(idx);
   end
end

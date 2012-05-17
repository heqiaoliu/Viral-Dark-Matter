function Axes = allaxes(this, varargin)
%ALLAXES  Get array of HG axes to making up plot.
%
%  Same as PLOT/ALLAXES, but also takes RowIndex and ColumnIndex 
%  into account.

%  Author(s): C. Buhr
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:27:48 $

% Get axes for entire @waveplot (4d array)
Axes = allaxes(this.Parent);

% Apply row and column indices
Axes = Axes(this.RowIndex,this.ColumnIndex,:,:);

% Reformat to 2D if requested
if any(strcmp(varargin,'2d'))
   s = size(Axes);
   Axes = reshape(permute(Axes,[3 1 4 2]),[s(1)*s(3),s(2)*s(4)]);
end
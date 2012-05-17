function dv = datavis(this)
%DATAVIS  Data visibility.
%
%  Responses are arrays of curves. Each curve represents a piece
%  of response data and is plotted in a particular HG axes.
%
%  DV = DATAVIS(RESPPLOT) returns an array of the same size as the
%  axes grid (see GETAXES) indicating which curves are currently
%  displayed.  The result is affected by the plot visibility,
%  the input and output visibility, and other parameters such
%  as the mag or phase visibility in Bode plots.

%  Author(s): P. Gahinet
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:20:07 $

% REVISIT: call parent method to initialize
gs = this.AxesGrid.Size;
dv = logical(zeros(gs([1 2])));
if strcmp(this.Visible,'on')
   % Row and column visibility (subgrid assumed 1x1 in generic case)
   dv(strcmp(this.OutputVisible,'on'),...
      strcmp(this.InputVisible,'on')) = logical(1);
end

% Factor in mag and phase visibility
if strcmp(this.Visible,'on')
   dv = cat(3,...
      dv & strcmp(this.MagVisible,'on'),...
      dv & strcmp(this.PhaseVisible,'on'));
else
    dv = cat(3,...
      dv & false,...
      dv & false);
end

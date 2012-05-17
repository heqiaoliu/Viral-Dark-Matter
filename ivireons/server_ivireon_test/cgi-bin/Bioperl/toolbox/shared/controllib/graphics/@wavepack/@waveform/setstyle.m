function setstyle(this,varargin)
%SETSTYLE  Applies user-defined style to @waveform instance.
%
%  SETSTYLE(WF,'r-x') specifies a color/linestyle/marker string.
%
%  SETSTYLE(WF,'Property1',Value1,...) specifies individual style 
%  attributes.  Valid properties include Color, LineStyle, LineWidth, 
%  and Marker.

%  Author(s): P. Gahinet, Karen Gondoly
%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:28:08 $

% if ~isempty(varargin{1})
%    % Create new @style instance to avoid corrupting style 
%    % manager's style pool
%    Style = wavepack.wavestyle;
%    Style.setstyle(varargin{:});
%    % Apply style
%    this.Style = Style;
% end

if ~isempty(varargin{1})
   % Create new @style instance to avoid corrupting style 
   % manager's style pool
   if isempty(this.Style)
       Style = wavepack.wavestyle;
   else
       Style = copy(this.Style);
   end
   Style.setstyle(varargin{:});
   % Apply style
   this.Style = Style;
end



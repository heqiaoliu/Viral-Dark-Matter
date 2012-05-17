function xfocus = getfocus(this,varargin)
%GETFOCUS  Computes optimal X limits for wave plot 
%          by merging Focus of individual waveforms.

%  Author(s):  
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $ $Date: 2005/12/15 20:58:31 $

%% Method to comput focus of xyplots. Optional second argument restricts
%% evaluation to a specific set of columns. Note that responses cannot be a
%% vector.
xfocus = [];
if ~isempty(this.Responses) && this.Responses.isvisible && ...
        ~isempty(this.Responses.Data) && ~this.Responses.Data.Exception
    if nargin>=2 && ~isempty(varargin{1})
        nonandata = this.Responses.Data.XData(...
            ~isnan(this.Responses.Data.XData(:,varargin{1})),varargin{1});
    else
        nonandata = this.Responses.Data.XData(~isnan(this.Responses.Data.XData));
    end
    if ~isempty(nonandata)
        xlow = min(nonandata);
        xhigh = max(nonandata);
        xfocus = [xlow xhigh];
    end
    if length(xfocus)>=2 && xfocus(2)==xfocus(1)
       xfocus(2) = xfocus(1)+eps;
    end
end

% Return something reasonable if empty.
if isempty(xfocus)
  xfocus = [0 1];
end



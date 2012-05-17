function [h,hAx] = getView(this,hAx) 
% GETVIEW create graphical representation of the requirement
%
% [h,hAx] = getView(this,hAx,idxIn,idxOut)
%
% Inputs:
%     this       - srorequirement.bodegain object
%     hAx        - optional axis handle where the requirement view is to be
%                  displayed. Can be an hg axis object or a respplot.plot object
%     inChannel  - Optional scalar indicating the input channel the view is for,
%                  only used for MIMO respplot.plot objects. If omitted the
%                  first input channel is assumed.
%     outChannel - Optional scalar indicating the output channel the view is for,
%                  only used for MIMO respplot.plot objects. If omitted the
%                  first input channel is assumed.
%
% Outputs:
%    h   - handle to created view, a plotconstr.designcontr object
%    hAx - handle to the axis the view is parented to.
 
% Author(s): A. Stothert 16-Aug-2007
% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:18 $

if nargin < 2 && nargout == 2, hAx = []; end
if nargout > 1, hAx = []; end
h = [];
ctrlMsgUtils.warning('Controllib:general:AbstractMethodMustBeOverloaded')

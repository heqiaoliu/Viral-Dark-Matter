function p = getoptions(this,varargin)
%GETOPTIONS  Get plot options from a Hankel singular value plot
%
%  P = GETOPTIONS(H) returns the plot options P for a HSV plot with 
%  handle H. See HSVPLOT for details on obtaining H. 
%
%  P = GETOPTIONS(H,PropertyName) returns the specified options property, 
%  for the Hankel singular value plot with handle H. 
% 
%  See also HSVPLOT, HSVOPTIONS, SETOPTIONS.

%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:21:00 $

if length(varargin)>1
    ctrlMsgUtils.error('Controllib:general:OneOrTwoInputsRequired','getoptions','wrfc/getoptions')
end

p = plotopts.HSVPlotOptions;
p.getHSVPlotOpts(this,true);

if ~isempty(varargin)
    try
        p = p.(varargin{1});
    catch
        ctrlMsgUtils.error('Controllib:plots:getoptions1','hsvoptions')
    end
end
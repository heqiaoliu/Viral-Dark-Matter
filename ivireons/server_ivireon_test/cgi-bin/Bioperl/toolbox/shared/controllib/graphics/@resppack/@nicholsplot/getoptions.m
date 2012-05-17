function p = getoptions(this,varargin)
%GETOPTIONS  Get plot options from a Nichols plot
%
%  P = GETOPTIONS(H) returns the plot options P for a Nichols plot with 
%  handle H. See NICHOLSPLOT for details on obtaining H. 
%
%  P = GETOPTIONS(H,PropertyName) returns the specified options property, 
%  for the Nichols plot with handle H. 
% 
%  See also NICHOLSPLOT, NICHOLSOPTIONS, SETOPTIONS.

%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:21:58 $

if length(varargin)>1
    ctrlMsgUtils.error('Controllib:general:OneOrTwoInputsRequired','getoptions','wrfc/getoptions')
end

p = plotopts.NicholsPlotOptions;
p.getNicholsPlotOpts(this,true);

if ~isempty(varargin)
    try
        p = p.(varargin{1});
    catch
        ctrlMsgUtils.error('Controllib:plots:getoptions1','nicholsoptions')
    end
end
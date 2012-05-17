function p = getoptions(this,varargin)
%GETOPTIONS  Get plot options from a singular value plot
%
%  P = GETOPTIONS(H) returns the plot options P for a singular value plot
%  with handle H. See SIGMAPLOT for details on obtaining H. 
%
%  P = GETOPTIONS(H,PropertyName) returns the specified options property, 
%  for the singular value plot with handle H. 
% 
%  See also SIGMAPLOT, SIGMAOPTIONS, SETOPTIONS.

%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:24:06 $

if length(varargin)>1
    ctrlMsgUtils.error('Controllib:general:OneOrTwoInputsRequired','getoptions','wrfc/getoptions')
end

p = plotopts.SigmaPlotOptions;
p.getSigmaPlotOpts(this,true);

if ~isempty(varargin)
    try
        p = p.(varargin{1});
    catch
        ctrlMsgUtils.error('Controllib:plots:getoptions1','sigmaoptions')
    end
end
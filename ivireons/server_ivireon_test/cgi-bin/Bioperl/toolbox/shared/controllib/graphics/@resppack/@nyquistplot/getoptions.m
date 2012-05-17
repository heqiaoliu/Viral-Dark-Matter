function p = getoptions(this, varargin)
%GETOPTIONS  Get plot options from a Nyquist plot
%
%  P = GETOPTIONS(H) returns the plot options P for a Nyquist plot with 
%  handle H. See NYQUISTPLOT for details on obtaining H. 
%
%  P = GETOPTIONS(H,PropertyName) returns the specified options property, 
%  for the Nyquist plot with handle H. 
% 
%  See also NYQUISTPLOT, NYQUISTOPTIONS, SETOPTIONS.

%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:22:25 $

if length(varargin)>1
    ctrlMsgUtils.error('Controllib:general:OneOrTwoInputsRequired','getoptions','wrfc/getoptions')
end

p = plotopts.NyquistPlotOptions;
p.getNyquistPlotOpts(this,true);

if ~isempty(varargin)
    try
        p = p.(varargin{1});
    catch
        ctrlMsgUtils.error('Controllib:plots:getoptions1','nyquistoptions')
    end
end
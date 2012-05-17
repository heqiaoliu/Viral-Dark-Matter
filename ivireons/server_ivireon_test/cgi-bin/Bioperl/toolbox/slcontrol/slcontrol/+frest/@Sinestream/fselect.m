function out = fselect(in,varargin)
% FSELECT  Obtain a new Sinestream signal from an existing one specifying a
% subset of frequencies or frequency range. 
%
%   IN_NEW = FSELECT(IN,FMIN,FMAX) selects the portion of the frequencies
%   between the frequencies FMIN and FMAX in the Sinestream signal IN and
%   returns a new Sinestream signal IN_NEW. The parameters corresponding to
%   each frequency in Sinestream signals IN and IN_NEW will be identical.
%   The selected range [FMIN,FMAX] should be expressed in the units of the original Sinestream. 
%
%   IN_NEW = FSELECT(IN,INDEX) selects the frequency points 
%   specified by the vector of indices INDEX in the Sinestream signal IN and
%   returns a new Sinestream signal IN_NEW. The parameters corresponding to
%   each frequency in Sinestream signals IN and IN_NEW will be identical.
 
% Author(s): Erman Korkut 11-Jun-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/08/08 01:18:47 $

% Check number of input & output arguments
ni = nargin;
error(nargchk(2,3,ni));
error(nargoutchk(0,1,nargout));

freqs = in.Frequency;

switch ni
    case 2
        index = varargin{1};
        if islogical(index)
            index = find(index);
        end
        if any(index<1 | index~=round(index))
            ctrlMsgUtils.error('Slcontrol:frest:FSelectNonIntegerIndex')
        elseif any(index>length(freqs))
            ctrlMsgUtils.error('Slcontrol:frest:FSelectIndexExceed')
        end
        % Take the unique elements only, in the same order
        [~,m,~] = unique(index,'first');
        index = index(sort(m));
    case 3
        index = find(freqs>=varargin{1} & freqs<=varargin{2});
        if isempty(index)
            ctrlMsgUtils.error('Slcontrol:frest:FSelectRangeEmpty')
        end
end

% Construct the new sinestream
out = frest.Sinestream(...
    'Frequency', in.Frequency(index),...
    'Amplitude', LocalGetParameterValues(in,'Amplitude',index),...
    'SamplesPerPeriod', LocalGetParameterValues(in,'SamplesPerPeriod',index),...
    'NumPeriods', LocalGetParameterValues(in,'NumPeriods',index),...
    'RampPeriods', LocalGetParameterValues(in,'RampPeriods',index),...
    'SettlingPeriods', LocalGetParameterValues(in,'SettlingPeriods',index),...
    'FreqUnits',in.FreqUnits,...
    'ApplyFilteringInFRESTIMATE',in.ApplyFilteringInFRESTIMATE,...
    'SimulationOrder',in.SimulationOrder,...
    'FixedTs',in.FixedTs);
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalGetParameterValues
%  Get the values of parameter param from existing sinestream signal in at
%  indices index.
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val = LocalGetParameterValues(in,param,index)
    val = in.(param);
    if ~isscalar(val)
        val = val(index);
    end    
end






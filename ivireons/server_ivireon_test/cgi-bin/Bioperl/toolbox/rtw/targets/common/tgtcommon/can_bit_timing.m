function [propseg, pseg1, pseg2, presdiv, sample] = ...
    can_bit_timing(fsys,bitrate,nq,sample_point)
%CAN_BIT_TIMING calculates bit timing values for the TouCAN module
% of a board in the Motorola MPC555 family.
%
%   This function takes the arguments
%     fsys           -  oscillator frequency
%     bitrate        -  the desired bit rate
%     nq             -  the number of segments in the bit
%     sample_point   -  the desired sample_point   0 < sample_point < 1
%
%   and returns
%     propseg        -  the number of propagation quanta
%     pseg1          -  phase segment 1 quanta
%     pseg2          -  phase segment 2 quanta
%     presdiv        -  prescaler divide to calculate oscillator freq
%     sample         -  the achieved sample point
%
% Example
%
%     [propseg,pseg1,pseg2,presdiv,sample] = can_bit_timing(20e6,500e3,20,0.81)

%   Copyright 2002-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $
%   $Date: 2009/12/07 20:43:53 $

presdiv =  fsys / (nq * bitrate);

%
% Check that the required pre-scaler is (nearly) a whole number
%
tolerance = 0.00001;
if(abs(round(presdiv) - presdiv) > tolerance)
  TargetCommon.ProductInfo.error('can', 'InvalidCANTimingSettings',...
    sprintf('%.5f',tolerance), num2str(fsys), num2str(nq), num2str(bitrate),...
    sprintf('%.10f',presdiv));
else
    % tolerance is ok; round to integer value
    presdiv = round(presdiv);
end

%
% Check that the sample point is in the required range
%
if ( sample_point <= 0 | sample_point >= 1 )
  TargetCommon.ProductInfo.error('can', 'InvalidSamplePoint');
end

% Candidate values for tseg1
TSEG1 = 2:(min(nq-1,16));

% Candidate values for sample
SAMPLE = (1 + TSEG1) / nq;

% Choose the best values for tseg1 and sample
[tmp,idx] = min(abs(SAMPLE - sample_point));
sample = SAMPLE(idx);
tseg1 = TSEG1(idx);

% Calculate remaining output arguments
propseg = floor(tseg1/2);
pseg1 = tseg1 - propseg;
pseg2 = nq -1 - propseg - pseg1;
 
   



   
  

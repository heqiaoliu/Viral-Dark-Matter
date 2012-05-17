function [output,mapping] = gray2bin(x,modulation,order)
%GRAY2BIN Gray decode
%   Y = GRAY2BIN(X,MODULATION,M) generates a Gray decoded output with the same
%   dimensions as its input parameter X. The input X can be a scalar, vector or
%   matrix.  MODULATION is the modulation type, which can be a string equal to
%   'qam', 'pam', 'fsk', 'dpsk' or 'psk'. M is the modulation order that must be
%   an integer power of two.
%
%   [Y,MAP] = GRAY2BIN(X,MODULATION,M) generates a Gray decoded output Y, and
%   returns its respective Gray encoded constellation map, MAP. The
%   constellation map is a vector of numbers to be assigned to the constellation
%   symbols. The assumed constellation symbols are same as the Constellation
%   property of MODEM objects. Type 'help modem' to get more information on
%   MODEM objects.
%
%   If you are demodulating Gray coded data, then converting it to binary coded
%   data immediately afterwards, you should use the appropriate demodulation
%   functions with the 'gray' option, instead of GRAY2BIN.
%
%   Example: 
%     % To Gray decode a vector x with a 16-QAM Gray encoded constellation and
%     % return its map, use:
%     x=randi([0 15],1,100);
%     [y,map] = gray2bin(x,'qam',16);
%
%     % Obtain the symbols for 16-QAM
%     hMod = modem.qammod('M', 16);
%     symbols = hMod.Constellation;
%
%     % Plot the constellation
%     scatterplot(symbols);
%     set(get(gca,'Children'),'Marker','d','MarkerFaceColor','auto');
%     hold on;
%     % Label the constellation points according to the Gray mapping
%     for jj=1:16
%       text(real(symbols(jj))-0.15,imag(symbols(jj))+0.15,...
%       dec2base(map(jj),2,4));
%     end
%     set(gca,'yTick',(-4:2:4),'xTick',(-4:2:4),...
%      'XLim',[-4 4],'YLim',...
%      [-4 4],'Box','on','YGrid','on', 'XGrid','on');
%
%   See also BIN2GRAY, MODEM, MODEM/TYPES, FSKDEMOD.

%   Copyright 1996-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2009/01/05 17:45:04 $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin validating inputs    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Typical error checking.
error(nargchk(3, 3, nargin,'struct'))

%Validate numeric x data
if isempty(x)
    error('comm:gray2bin:InputEmpty','Input data vector is empty.');
end

% x must be a scalar, vector or a 2D matrix
if length(size(x)) > 2
    error('comm:gray2bin:InputDimensions','Input data must be a scalar, vector or a 2D matrix.');
end

% x must be a finite non-negative integer
if (max(max(x < 0))) || (max(max(isinf(x)))) || (~isreal(x))...
        || (max(max(floor(x) ~= x)))

    error('comm:gray2bin:InputError','Input data must contain only finite real non-negative integers.');

end

% Validate modulation type
if (~ischar(modulation)) || (~strcmpi(modulation,'QAM')) && (~strcmpi(modulation,'PSK'))...
        && (~strcmpi(modulation,'FSK')) && (~strcmpi(modulation,'PAM')) && (~strcmpi(modulation,'DPSK'))

    error('comm:gray2bin:ModulationTypeError','Invalid modulation type.');

end

%Validate modulation order
if (order < 2) || (isinf(order) || ...
        (~isreal(order)) || (floor(log2(order)) ~= log2(order)))

    error('comm:gray2bin:ModulationOrderError','Modulation order must be a finite real positive - integer power of 2.');

end

% Check for overflows
if (max(max(x)) >= order)
    error('comm:gray2bin:XError','Elements of input X must be integers in the range [0, M-1].');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Finished validating inputs      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start Gray code conversion %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch lower(modulation)

    case {'psk','pam','fsk','dpsk'}

        % Calculate map
        j = (0:order-1)';
        mapping = bitxor(j,bitshift(j,-1));

        % Format output and translate x (map) i.e. Gray Decode
        [tf,index]=ismember(x,mapping);
        output=index-1;

    case {'qam'}

        k = log2(order);                % Number of bits per symbol
        mapping = (0:order-1)';         % Binary mapping to be Gray converted
        if rem(k,2) % non-square constellation

            kI = (k+1)/2;
            kQ = (k-1)/2;

            symbolI = bitshift(mapping,-kQ);
            symbolQ = bitand(mapping,bitshift(order-1,-kI));

            % while i is smaller (Number of bits per symbol)/2
            i = 1;
            while i < kI
                tempI = symbolI;
                tempI = bitshift(tempI,-i);
                symbolI = bitxor(symbolI,tempI);
                i = i + i;                          % i takes on values 1,2,4,8,...,2^n - n is an integer
            end

            % while i is smaller (Number of bits per symbol)/2
            i = 1;
            while i < kQ
                tempQ = symbolQ;
                tempQ = bitshift(tempQ,-i);
                symbolQ = bitxor(symbolQ, tempQ);
                i = i + i;                          % i takes on values 1,2,4,8,...,2^n - n is an integer
            end

            SymbolIndex = double(bitshift(symbolI,kQ) + symbolQ);

        else % square constellation

            symbolI = bitshift(mapping,-k/2);
            symbolQ = bitand(mapping,bitshift(order-1,-k/2));

            % while i is smaller (Number of bits per symbol)/2
            i = 1;
            while i < k/2
                tempI = symbolI;
                tempI = bitshift(tempI,-i);
                symbolI = bitxor(symbolI,tempI);

                tempQ = symbolQ;
                tempQ = bitshift(tempQ,-i);
                symbolQ = bitxor(symbolQ, tempQ);
                i = i + i;                          % i takes on values 1,2,4,8,...,2^n - n is an integer
            end

            SymbolIndex = double(bitshift(symbolI,k/2) + symbolQ);

        end

        mapping = SymbolIndex;

        % Make sure that mapping is a vector, when used to name the symbols
        % column-wise starting from left upper corner, results in a gray mapped
        % constellation.
        [dummy,index]=ismember(0:order-1,mapping);
        mapping = index - 1;
        
        % We can use this new mapping to decode Gray encoding
        %Format output and translate x (map) i.e. Gray decode
        output = mapping(x+1);

        % Assure that the output, if one dimensional,
        % has the correct orientation
        if any(size(x) ~= size(output))
            output = output';
        end

    otherwise
        error('comm:gray2bin:ModulationTypeUnknown','Unknown modulation method.')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Gray code conversion %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Hd = coupledallpass(this,struct,s)
%COUPLEDALLPASS

%   Author(s): R. Losada
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/09 23:46:41 $


% Initialize vector to store poles
ns = size(s,1);
p = zeros(2*ns,1);

for k = 1:ns,
    p(2*k-1:2*k) = roots(s(k,4:6));
end

% Remove fake pole (for lp/hp)
p(p==0)=[];


% Work only with poles on upper half of unit circle
p = p(imag(p)>=0);
p = sort(p); % Sort by magnitude and angle
p0 = p(end);
p = p(1:end-1);

if isreal(p0),
    [y,idx]=min(abs(p0-p));
    if isreal(p(idx)),
        allpass_poly = conv([1 -p0],[1 -p(idx)]);
        p0 = p(idx);
        p(idx) = [];
    else
        allpass_poly = [1 -p0];
    end
else
    allpass_poly = conv([1 -p0],[1 -conj(p0)]);
end
branch2 = {real(allpass_poly(2:end))};
b2count = 2;

branch1 = {};
b1count = 1;
k = 1;
while ~isempty(p),
    % Find pole closest to p0
    [y,idx]=min(abs(p0-p));
    p0 = p(idx);
    p(idx) = [];
    if isreal(p0),
        if ~isempty(p),
            % Find the other real pole
            ptemp = p;
            ptemp(imag(p)~=0)=inf;
            [y,idx]=min(abs(p0-ptemp));
            allpass_poly = conv([1 -p0],[1 -p(idx)]);
            p0 = p(idx);
            p(idx) = [];
        else
            allpass_poly = [1 -p0];
        end
    else
        allpass_poly = conv([1 -p0],[1 -conj(p0)]);
    end
    if rem(k,2) == 1,
        branch1{b1count} = real(allpass_poly(2:end));
        b1count = b1count + 1;
    else
        branch2{b2count} = real(allpass_poly(2:end));
        b2count = b2count + 1;
    end
    k = k + 1;
end


Hd = createcaobj(this,struct,branch1,branch2);


% [EOF]

function ps = paper_size(type)

% Copyright 2005 The MathWorks, Inc.

    ps = [0 0];
    switch(type)
      case 'usletter'
        ps = [8.5 11];
      case 'uslegal'
        ps = [8.5 14];
      case 'A0'
        ps = [33.1354 46.8466];
      case 'A1'
        ps = [23.4036 33.1354];
      case 'A2'
        ps = [16.5480 23.4036];
      case 'A3'
        ps = [11.6944 16.5278];
      case 'A4'
        ps = [8.267716 11.692913];
      case 'B0'
        ps = [40.5426 57.3664];
      case 'B1'
        ps = [28.6832 40.5032];
      case 'B2'
        ps = [20.2516 28.6832];
      case 'B3'
        ps = [14.3416 20.2516];
      case 'B4'
        ps = [10.1258 14.3416];
      case 'B5'
        ps = [7.1708 10.1258];
      case 'arch-A'
        ps = [9 12];
      case 'arch-B'
        ps = [12 18];
      case 'arch-C'
        ps = [18 24];
      case 'arch-D'
        ps = [24 36];
      case 'arch-E'
        ps = [36 48];
      case 'tabloid'
        ps = [11 17];
    end
end

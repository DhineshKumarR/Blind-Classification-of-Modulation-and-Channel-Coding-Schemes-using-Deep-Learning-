
% This modulator function performs bit-to-symbol mapping.
% Inputs:
%   bits_in = input bits
%   level   = modulation level (1:BPSK; 2:QPSK; 3:8PSK; 4: 16QAM; 6:64QAM)
%             The modulation level is how many bits each symbol represents 
% Outputs:
%   mod_symbols = modulated symbols



function mod_symbols = modulator(bits_in, level)

full_len = length(bits_in);

% BPSK modulation
if (level==1)
    %0->-1; 1->1
    table=exp(j*[-pi 0]);  % generates BPSK symbols
    inp=bits_in;
    mod_symbols=table(inp+1);  % maps transmitted bits into BPSK symbols

    % QPSK modulation
elseif (level==2)
    %00->-3*pi/4,01->3*pi/4,10->-pi/4,11->pi/4
    table=exp(j*[-3/4*pi 3/4*pi -1/4*pi 1/4*pi]); % generates QPSK symbols
    inp=bi2de(reshape(bits_in,2,full_len/2).','left-msb');
    mod_symbols=table(inp+1);  % maps transmitted bits into QPSK symbols
    
    % 8PSK modulation
elseif (level==3)
    table = exp(j*([1/8*pi 7/8*pi 3/8*pi 5/8*pi -1/8*pi -7/8*pi -3/8*pi -5/8*pi]));
    inp=bi2de(reshape(bits_in,3,full_len/3).','left-msb');
    mod_symbols=table(inp+1);  % maps transmitted bits into QPSK symbols

    % 16-QAM modulation
elseif (level==4)
    %0000->(-3,-3),0001->(-3,-1),0010->(-3,+3),0011->(-3,+1),0100->(-1,-3),
    %0101->(-1,-1),0110->(-1,+3),0111->(-1,+1),1000->(+3,-3),1001->(+3,-1),
    %1010->(+3,+3),1011->(+3,+1),1100->(+1,-3),1101->(+1,-1),
    %1110->(+1,+3),1111->(+1,+1)
    % generates 16QAM symbols
    table = [(-3-3*j)/sqrt(10) (-3-1*j)/sqrt(10) (-3+3*j)/sqrt(10) (-3+1*j)/sqrt(10) ...
        (-1-3*j)/sqrt(10) (-1-1*j)/sqrt(10) (-1+3*j)/sqrt(10) (-1+1*j)/sqrt(10) ...
        (+3-3*j)/sqrt(10) (+3-1*j)/sqrt(10) (+3+3*j)/sqrt(10) (+3+1*j)/sqrt(10) ...
        (+1-3*j)/sqrt(10) (+1-1*j)/sqrt(10) (+1+3*j)/sqrt(10) (+1+1*j)/sqrt(10)];

    inp=reshape(bits_in,4,full_len/4).';
    inptmp = bi2de(inp,2,'left-msb');
    mod_symbols = table(inptmp+1);

    % 64-QAM modulation
elseif (level==6)
    % generates 64QAM symbols
    table = [(-7-7*j)/sqrt(42) (-7-5*j)/sqrt(42) (-7-1*j)/sqrt(42) (-7-3*j)/sqrt(42) ...
        (-7+7*j)/sqrt(42) (-7+5*j)/sqrt(42) (-7+1*j)/sqrt(42) (-7+3*j)/sqrt(42) ...
        (-5-7*j)/sqrt(42) (-5-5*j)/sqrt(42) (-5-1*j)/sqrt(42) (-5-3*j)/sqrt(42) ...
        (-5+7*j)/sqrt(42) (-5+5*j)/sqrt(42) (-5+1*j)/sqrt(42) (-5+3*j)/sqrt(42) ...
        (-1-7*j)/sqrt(42) (-1-5*j)/sqrt(42) (-1-1*j)/sqrt(42) (-1-3*j)/sqrt(42) ...
        (-1+7*j)/sqrt(42) (-1+5*j)/sqrt(42) (-1+1*j)/sqrt(42) (-1+3*j)/sqrt(42) ...
        (-3-7*j)/sqrt(42) (-3-5*j)/sqrt(42) (-3-1*j)/sqrt(42) (-3-3*j)/sqrt(42) ...
        (-3+7*j)/sqrt(42) (-3+5*j)/sqrt(42) (-3+1*j)/sqrt(42) (-3+3*j)/sqrt(42) ...
        (+7-7*j)/sqrt(42) (+7-5*j)/sqrt(42) (+7-1*j)/sqrt(42) (+7-3*j)/sqrt(42) ...
        (+7+7*j)/sqrt(42) (+7+5*j)/sqrt(42) (+7+1*j)/sqrt(42) (+7+3*j)/sqrt(42) ...
        (+5-7*j)/sqrt(42) (+5-5*j)/sqrt(42) (+5-1*j)/sqrt(42) (+5-3*j)/sqrt(42) ...
        (+5+7*j)/sqrt(42) (+5+5*j)/sqrt(42) (+5+1*j)/sqrt(42) (+5+3*j)/sqrt(42) ...
        (+1-7*j)/sqrt(42) (+1-5*j)/sqrt(42) (+1-1*j)/sqrt(42) (+1-3*j)/sqrt(42) ...
        (+1+7*j)/sqrt(42) (+1+5*j)/sqrt(42) (+1+1*j)/sqrt(42) (+1+3*j)/sqrt(42) ...
        (+3-7*j)/sqrt(42) (+3-5*j)/sqrt(42) (+3-1*j)/sqrt(42) (+3-3*j)/sqrt(42) ...
        (+3+7*j)/sqrt(42) (+3+5*j)/sqrt(42) (+3+1*j)/sqrt(42) (+3+3*j)/sqrt(42)];

    inp=reshape(bits_in,6,full_len/6).';
    inptmp = bi2de(inp,2,'left-msb');
    mod_symbols = table(inptmp+1);

else
    error('Unimplemented modulation');
end



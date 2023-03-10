% This program simulates the channel coding
clear all
%% Channel Coding with BPSK Modulation
%% Simulation parameters
%% Define the simulated SNR points
EbN0dB = 7;
No     =   8;

%% modulation level 1==>BPSK; 2==>QPSK, 3==>8PSK; 4==>16QAM; 6==>64QAM
mod_level = 1; 

Rc=1/2;  % code rate of the employed convolutional code

%% convert convolutional code polynomial to trellis description
%% we use (133,171) code with constraint length equal to 7.
t = poly2trellis(7, [133 171]);

number_bits_per_frame = No*mod_level;
number_info_bits_per_frame = number_bits_per_frame*Rc;

%% calculate the noise variance n0 here
n0 = 10.^(-(EbN0dB)/10)./(mod_level*Rc);

%% initialize BER value for each simulated SNR value
CH1 = zeros(16,50) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 for a = 1:50
    
        %% Generate uncoded bits  
        uncoded_bits = rand(1,number_info_bits_per_frame)>.5;    
        
        %% Channel encoding
        coded_bits = convenc(uncoded_bits, t);      
                
        %% Derive random interleaver
%         [temp inter_index] = sort(rand(1,length(coded_bits)));
        
        %% Perform interleaving
%          interleaved_bits = coded_bits(inter_index);
         
        %% Modulation: Bits-to-Sybmol Mapping
        transmitted_symbols = modulator(coded_bits,mod_level);
             TX1 = transmitted_symbols;
             
        %% Signal passing through AWGN channel and Rayeleigh fading channel    
        Noise1=sqrt(n0)*sqrt(0.5)*(randn(1,No)+1i*randn(1,No));   
          H = (randn(1,1) + 1i*randn(1,1));
          RX1 = conv(TX1,H) + Noise1;
          RX1 = (RX1).';
          y0 = real(RX1);
          y1 = imag(RX1);
          CH1(:,a)= [y0 ; y1];
 end
 CH1_1 = [CH1; ones(1,50)] ;
 CH1_2 = [CH1_1; zeros(1,50)] ;
%  CH1_2 = [CH1_2; zeros(1,25)] ;
%  CH1_2 = [CH1_2; ones(1,25)] ;
 CH1_2 = [CH1_2; ones(1,50)] ;
%%Channel Coding with QPSK Modulation 
        
%% Simulation parameters
%% Define the simulated SNR points
% EbN0dB1 = 25;
% No1     =   8;
% 
% %% modulation level 1==>BPSK; 2==>QPSK, 3==>8PSK; 4==>16QAM; 6==>64QAM
% mod_level1 = 2; 
% 
% Rc1=1/2;  % code rate of the employed convolutional code
% 
% %% convert convolutional code polynomial to trellis description
% %% we use (133,171) code with constraint length equal to 7.
% t1 = poly2trellis(7, [133 171]);
% 
% number_bits_per_frame1 = No1*mod_level1;
% number_info_bits_per_frame1 = number_bits_per_frame1*Rc1;
% 
% %% calculate the noise variance n0 here
% n01 = 10.^(-(EbN0dB1)/10)./(mod_level1*Rc1);
% 
% %% initialize BER value for each simulated SNR value
% CH2 = zeros(16,25) ;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%  for a1 = 1:25
%     
%         %% Generate uncoded bits  
%         uncoded_bits1 = rand(1,number_info_bits_per_frame1)>.5;    
%         
%         %% Channel encoding
%         coded_bits1 = convenc(uncoded_bits1, t1);      
%                 
%         %% Derive random interleaver
% %         [temp inter_index] = sort(rand(1,length(coded_bits)));
%         
%         %% Perform interleaving
% %          interleaved_bits = coded_bits(inter_index);
%          
%         %% Modulation: Bits-to-Sybmol Mapping
%         transmitted_symbols1 = modulator(coded_bits1,mod_level1);
%              TX2 = transmitted_symbols1;
%              
%         %% Signal passing through AWGN channel and Rayeleigh fading channel    
%         Noise2=sqrt(n01)*sqrt(0.5)*(randn(1,No1)+1i*randn(1,No1));   
%           H1 = (randn(1,1) + 1i*randn(1,1));
%           RX2 = conv(TX2,H1) + Noise2;
%           RX2 = (RX2).';
%           y2 = real(RX2);
%           y3 = imag(RX2);
%           CH2(:,a1)= [y2 ; y3];
%  end
%   CH2_1 = [CH2; zeros(1,25)] ;
%   CH2_2 = [CH2_1; zeros(1,25)] ;
%   CH2_2 = [CH2_2; ones(1,25)] ;
%   CH2_2 = [CH2_2; zeros(1,25)] ;
%   CH2_2 = [CH2_2; zeros(1,25)+2] ;
%   %% Shuffling
%   CH_2 = [CH1_2  CH2_2];
% CHI = CH_2(:,randperm(size(CH_2,2)));
 %% uncoded bits with BPSK Modulation
 
 %% Simulation parameters
%% Define the simulated SNR points

%% Bits generation
snrdB1=7; 
snr1=10^(snrdB1/10); 
L12 = 50;
No11=8;
RX12 = zeros(16,50);
for a12 = 1:L12
uncoded_bits12 = rand(1,No11)>.5;  
mod_level12 = 1;
transmitted1= modulator(uncoded_bits12,mod_level12);
Tx12 = (transmitted1);
%% Plot of transmitted symbols
% figure(1),plot(Tx12,'o');
% axis([-2 2 -2 2]);
% grid on;
% xlabel('real'); ylabel('imaginary');
% title('BPSK constellation');
%% Signal passing through AWGN channel    
Noise13=sqrt(1/snr1)*sqrt(0.5)*(randn(1,No11)+1i*randn(1,No11));   
H2 = (randn(1,1) + 1i*randn(1,1));
Y12=conv(Tx12,H2)+Noise13;        %received signal
%% Plot of transmitted symbols
% figure(2),plot(Y12,'o');
% axis([-2 2 -2 2]);
% grid on;
% xlabel('real'); ylabel('imaginary');
% title('BPSK constellation affected by noise');
Y12 = (Y12).';
y01 = real(Y12);
y11 = imag(Y12);
RX12(:,a12)= [y01 ; y11];
end
% %%QPSK uncoded bits
% L21=25;    
% N1_12=16;   
% RX23=zeros(16,25);
% for b2=1:L21 
% uncoded_bits23 = rand(1,N1_12)>.5; 
% mod_level23 = 2;
% transmitted13= modulator(uncoded_bits23,mod_level23);
% Tx23 = (transmitted13);
% %% Plot of transmitted symbols
% % figure(3),plot(Tx23,'o');
% % axis([-2 2 -2 2]);
% % grid on;
% % xlabel('real'); ylabel('imaginary');
% % title('QPSK constellation');
% %% Signal passing through AWGN channel    
% Noise24=sqrt(1/snr1)*sqrt(0.5)*(randn(1,N1_12/2)+1i*randn(1,N1_12/2));  
% H3 = (randn(1,1) + 1i*randn(1,1));
% Y23=conv(Tx23,H3)+Noise24;        %received signal
% %% Plot of transmitted symbols
% % figure(4),plot(Y23,'o');
% % axis([-2 2 -2 2]);
% % grid on;
% % xlabel('real'); ylabel('imaginary');
% % title('QPSK constellation affected by noise');
% Y23 = (Y23).';
% y24 = real(Y23);
% y34 = imag(Y23);
% RX23(:,b2) = [y24 ; y34];
% end
RX1_12 = [RX12; zeros(1,50)] ;
% RX1_23 = [RX23; ones(1,25)] ;
RX1_12(18,:) = ~ RX1_12(17,:);
RX1_12(19,:) =  RX1_12(18,:)+1;
% RX1_12(20,:) =  RX1_12(19,:);
% RX1_12(21,:) =  RX1_12(20,:)+3;
% RX1_23(18,:) = ~ RX1_23(17,:);
% RX1_23(19,:) =  RX1_23(18,:);
% RX1_23(20,:) =  RX1_23(19,:);
% RX1_23(21,:) =  RX1_23(20,:)+4;
% rx1 = [RX1_12  RX1_23];
% RX4 = rx1(:,randperm(size(rx1,2)));
%% Shuffling of Coding and Uncoded bits
TXC_U_1 = [CH1_2 RX1_12];
TXC_U = TXC_U_1(:,randperm(size(TXC_U_1,2)));
%% Save the input datas
testdata_dc2_25dB_100 = TXC_U;
save('testdata_dc2_25dB_100','testdata_dc2_25dB_100');
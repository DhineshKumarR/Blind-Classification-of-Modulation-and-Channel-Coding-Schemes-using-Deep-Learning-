clear all
%% Bits generation
snrdB=25; 
snr=10^(snrdB/10); 
L1 = 1000;
No=8;
RX1 = zeros(16,1000);
for a = 1:L1
uncoded_bits1 = rand(1,No)>.5;  
mod_level1 = 1;
transmitted= modulator(uncoded_bits1,mod_level1);
Tx1 = (transmitted);
%% Plot of transmitted symbols
% figure(1),plot(Tx1,'o');
% axis([-2 2 -2 2]);
% grid on;
% xlabel('real'); ylabel('imaginary');
% title('BPSK constellation');
%% Signal passing through AWGN channel    
Noise1=sqrt(1/snr)*sqrt(0.5)*(randn(1,No)+1i*randn(1,No));   
Y1=Tx1+Noise1;        %received signal
%% Plot of transmitted symbols
% figure(2),plot(Y1,'o');
% axis([-2 2 -2 2]);
% grid on;
% xlabel('real'); ylabel('imaginary');
% title('BPSK constellation affected by noise');
Y1 = (Y1).';
y0 = real(Y1);
y1 = imag(Y1);
RX1(:,a)= [y0 ; y1];
end
%% QPSK
L2=1000;    
N1_1=16;   
RX2=zeros(16,1000);
for b=1:L2 
uncoded_bits2 = rand(1,N1_1)>.5; 
mod_level2 = 2;
transmitted1= modulator(uncoded_bits2,mod_level2);
Tx2 = (transmitted1);
%% Plot of transmitted symbols
% figure(3),plot(Tx2,'o');
% axis([-2 2 -2 2]);
% grid on;
% xlabel('real'); ylabel('imaginary');
% title('QPSK constellation');
%% Signal passing through AWGN channel    
Noise2=sqrt(1/snr)*sqrt(0.5)*(randn(1,N1_1/2)+1i*randn(1,N1_1/2));   
Y2=Tx2+Noise2;        %received signal
%% Plot of transmitted symbols
% figure(4),plot(Y2,'o');
% axis([-2 2 -2 2]);
% grid on;
% xlabel('real'); ylabel('imaginary');
% title('QPSK constellation affected by noise');
Y2 = (Y2).';
y2 = real(Y2);
y3 = imag(Y2);
RX2(:,b) = [y2 ; y3];
end
RX1_1 = [RX1; ones(1,1000)] ;
RX1_2 = [RX2; zeros(1,1000)] ;
RX1_1(18,:) = ~ RX1_1(17,:);
RX1_1(19,:) =  RX1_1(18,:)+1;
RX1_2(18,:) = ~ RX1_2(17,:);
RX1_2(19,:) =  RX1_2(18,:)+1;
rx = [RX1_1  RX1_2];
RX = rx(:,randperm(size(rx,2)));
%%--------------------------------------------------------------------------------------------
a1 = rand(8,1)>.5;
transmitted2 = modulator(a1,mod_level1);
a3_1 = real(transmitted2);
transmitted3 = modulator(a1,mod_level2);
a2_1 = real(transmitted3);
a2_2 = imag(transmitted3);
a2_3 = [a2_1 a2_2];
a2 = (a2_3)';
a3 = (a3_1)';
%% -------------------------------------------------------------------------------------------
%% Deep Learning
traindata_1 = [a3 ; a2];
testdata_1 = traindata_1(randperm(size(traindata_1,1)),:);
%%--------------------------------------------------------------------------------------------
%%input data for training
traindata_25dB_1000 = RX;
%%-----------------------------------------------------------------------------------------------
save('traindata_25dB_1000','traindata_25dB_1000'); 
%%target dtat for classification
% nodeTarget = traindata((17),:);
clc;
clear;
close all;

load('traindata.mat');
nodeTarget = traindata((17:18),:);
Tr = traindata([1:16],:);

% load('/home/ris-ksrao/Desktop/HMM-ANN/RM/MFCC.mat');
% load('/home/ris-ksrao/Desktop/HMM-ANN/RM/nodeTargetRM.mat');
% nodeTarget =nodeTargetRM;
% % MFCC = normalise(MFCC);
% MFCC_New=[];
% Targ_New = [];
% for i=1:size(nodeTarget,1)
%     X = find(nodeTarget(i,:)==1);
%     G = MFCC(X,:);
%     H = nodeTarget(:,X);
%     MFCC_New = [MFCC_New;G];
%     Targ_New = [Targ_New H];
%   clearvars X G H;
% end

% % train the network with considerable examples not more
% for sel=0:26
% SS = find(Targ_New(sel+1,:)==1);
% NewSS(sel*100+1:(sel+1)*100) = SS(1:100);
% clear SS;
% end
% redTarget = Targ_New(:,NewSS); % reduced target
% redMFCC = MFCC_New(NewSS,:); % reduced MFCC
% Tr = redMFCC';
% % T = redTarget;
% Ttarg = zeros(27,2700);
% for targ=0:26
%     Ttarg(targ+1,[targ*100+1:(targ+1)*100])=1;
% end
T = nodeTarget;
stp_err = 10e-4; % goal error
W1=randn(20,16);% replace 39 by ur feat dim
W2=randn(20,20);
W3=randn(2,20);
n1=W1*Tr;
A1=logsig(n1);
n2=W2*A1;
A2=logsig(n2);
n3=W3*A2;
A3=logsig(n3);

e=T-A3;%err at op layer
eh2=W3'*e;
eh=W2'*eh2;
error =0.5* mean(mean(e.*e));    

n_ep=50000;%max. no. of iterations

for m=1:n_ep
    if error <= stp_err 
        break
    else
n1=W1*Tr;
A1=logsig(n1);
n2=W2*A1;
A2=logsig(n2);
n3=W3*A2;
A3=logsig(n3);

e=T-A3;%err at op layer
eh2=W3'*e;
eh=W2'*eh2;
error =0.5* mean(mean(e.*e));
% sumAA = A3/sum(A3);
% % logLik = log(prod(sumAA));
% logLik = log(sum(sumAA));
% lA3 = log(A3);
% logLik = sum(lA3,2);
% avgLogLikeli(:,m) = logLik;
avgError(m) = error;
disp(error)
nntwarn off
W3=W3+0.001*(e'.*(A3.*(1-A3))')'*A2';
W2=W2+0.001*(eh2'.*(A2.*(1-A2))')'*A1';
W1=W1+0.001*(eh'.*(A1.*(1-A1))')'*Tr';
    end
end
disp('the stopping criteria is')
disp(m)
figure(1);
plot(avgError);
xlabel('Epoch'); ylabel('Error');
title('Error vs Epoch (Model optimisation)');

% Testing
load('testdata.mat');
for n= 1:100
test(1:16,n) = testdata([1:16],n);
n1T=W1*test(1:16,n);
A1T=logsig(n1T);
n2T=W2*A1T;
A2T=logsig(n2T);
n3T=W3*A2T;
A3T=logsig(n3T);
TtestExp=[1 0 ; 0 1]';
errorTest=TtestExp-repmat(A3T,1,2);%err at op layer
[errorT,inx] =min(mean(errorTest.*errorTest));
out(1:16,n)=inx;
fprintf('Test vector belongs to class-%s\n',out);
end
% load('testdata.mat');
% test = testdata([1:16],11);
% n1T=W1*test;
% A1T=logsig(n1T);
% n2T=W2*A1T;
% A2T=logsig(n2T);
% n3T=W3*A2T;
% A3T=logsig(n3T);
% TtestExp=[1 0 ;0 1]';
% errorTest=TtestExp-repmat(A3T,1,2);%err at op layer
% [errorT,inx] =min(mean(errorTest.*errorTest));
% fprintf('Test vector belongs to class-%s\n',num2str(inx));
err = testdata(18,:)+1
t1=string(out(16,:))
err=string(err)
terr=strcmp(err,t1)
accuracy=sum(terr)/2
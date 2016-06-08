clear
clc

% load('d1_272_our.mat')
% load('d1_403_our.mat')
% load('d1_427_our.mat')
% load('d1_428_our.mat')
load('d9_584_our.mat')

RR = [];

k_idx = 1;
Pair = cell2mat(Okay(1:5,k_idx));
Pair2 = Okay2{k_idx};
Pair3 = Okay3{k_idx};
[~,~,~,auc1] = perfcurve(Pair(:,1),Pair(:,2),1);
RR = [RR, auc1];

RE = [];

auc2 = [];
for i=1:4
    [X_axis,Y_axis,~,auc2(i)] = perfcurve(Pair2(:,2*i-1),Pair2(:,2*i),1); 
end
auc3 = [];
for i=1:4*3
    [X_axis,Y_axis,~,auc3(i)] = perfcurve(Pair3(:,2*i-1),Pair3(:,2*i),1);
end
auc2 = auc2';
auc4 = reshape(auc3,[3,4])';
auc5 = [auc2,auc4];

RE = [RE; auc5];

k_idx = 2;
Pair = cell2mat(Okay(1:5,k_idx));
Pair2 = Okay2{k_idx};
Pair3 = Okay3{k_idx};
[~,~,~,auc1] = perfcurve(Pair(:,1),Pair(:,2),1);
RR = [RR, auc1];

auc2 = [];
for i=1:4
    [X_axis,Y_axis,~,auc2(i)] = perfcurve(Pair2(:,2*i-1),Pair2(:,2*i),1); 
end
auc3 = [];
for i=1:4*3
    [X_axis,Y_axis,~,auc3(i)] = perfcurve(Pair3(:,2*i-1),Pair3(:,2*i),1);
end
auc2 = auc2';
auc4 = reshape(auc3,[3,4])';
auc5 = [auc2,auc4];

RE = [RE; auc5];

k_idx = 3;
Pair = cell2mat(Okay(1:5,k_idx));
Pair2 = Okay2{k_idx};
Pair3 = Okay3{k_idx};
[~,~,~,auc1] = perfcurve(Pair(:,1),Pair(:,2),1);
RR = [RR, auc1];

auc2 = [];
for i=1:4
    [X_axis,Y_axis,~,auc2(i)] = perfcurve(Pair2(:,2*i-1),Pair2(:,2*i),1); 
end
auc3 = [];
for i=1:4*3
    [X_axis,Y_axis,~,auc3(i)] = perfcurve(Pair3(:,2*i-1),Pair3(:,2*i),1);
end
auc2 = auc2';
auc4 = reshape(auc3,[3,4])';
auc5 = [auc2,auc4];

RE = [RE; auc5];
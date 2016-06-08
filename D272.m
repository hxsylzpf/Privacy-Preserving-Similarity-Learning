% 272 - Our system

clear
clc

Data_tmp = csvread('d_272.csv'); % (should be changed depending on the disease)
Data = Data_tmp(:,2:end);
pos = Data(find(Data(:,1)==1),:);
neg = Data(find(Data(:,1)==0),:);
ind_neg = randperm(length(neg),size(pos,1))';
Data_1 = [pos; neg(ind_neg,:)];
order = randperm(length(Data_1));
Data_new = Data_1(order,:);
Class = Data_new(:,1);
Features = zscore(Data_new(:,2:end));

fold = 5;
indices = crossvalind('Kfold',length(Class),fold);

save('d_272_data','Class','Features','indices')

N = 100*ones(1,3); % 100 patients x 3 sites
N_tst = round(N/4); % 25 patients x 3 sites
B = [12,262,814,204,1338,170];
D = [2,10,10,10,10,10];

rep = 100;

k_nn = [1,3,9];

Okay2 = cell(1,length(k_nn));
Okay3 = cell(1,length(k_nn));
Okay = [];
    
for K = 1:fold
    tst = (indices == K);
    trn = ~tst;
    
    Class_trn = Class(trn,1);
    Features_trn = Features(trn,:);
    Class_tst = Class(tst,1);
    Features_tst = Features(tst,:);
    
    tmp1 = 0;
    for i=1:length(N)
        y{i} = Class_trn((tmp1+1):(tmp1+N(i)),1);
        tmp2 = 0;
        for k=1:length(B)
            X{1,k,i} = Features_trn((tmp1+1):(tmp1+N(i)),(tmp2+1):((tmp2+B(k))));
            tmp2 = tmp2+B(k);
        end
        tmp1 = tmp1+N(i);
    end
    
    tmp1 = 0;
    for i=1:length(N_tst)
        y_tst{i} = Class_tst((tmp1+1):(tmp1+N_tst(i)),1);
        tmp2 = 0;
        for k=1:length(B)
            X_tst{1,k,i} = Features_tst((tmp1+1):(tmp1+N_tst(i)),(tmp2+1):((tmp2+B(k))));
            tmp2 = tmp2+B(k);
        end
        tmp1 = tmp1+N_tst(i);
    end
    
    tmp = JH_Fun(X,X_tst,y,y_tst,N,B,D,rep,k_nn);
    Okay = [Okay;tmp];
    
    for nei=1:length(k_nn)
        
        rslt_knn1_tst = [];
        rslt_knn2_tst = [];
        
        num = k_nn(nei);
        
        for kind = 1:4
            if kind == 1
                distance = 'euclidean';
            elseif kind == 2
                distance = 'cityblock';
            elseif kind == 3
                distance = 'cosine';
            elseif kind == 4
                distance = 'correlation';
            end
            
            MDl = fitcknn(Features_trn(1:sum(N),:),Class_trn(1:sum(N),1),'NumNeighbors',num,'Standardize',0,'Distance', distance);
            [Class_hat_tst, Prob_hat_tst] = predict(MDl,Features_tst(1:sum(N_tst),:));
            rslt_knn1_tst = [rslt_knn1_tst, [Class_tst(1:sum(N_tst),1), Prob_hat_tst(:,2)]];
            
            tmp1 = 0;
            tmp2 = 0;
            for i=1:length(N_tst)
                MDl = fitcknn(Features_trn((tmp1+1):(tmp1+N(i)),:),Class_trn((tmp1+1):(tmp1+N(i)),1),'NumNeighbors',num,'Standardize',0,'Distance', distance);
                [Class_hat_tst, Prob_hat_tst] = predict(MDl,Features_tst((tmp2+1):(tmp2+N_tst(i)),:));
                rslt_knn2_tst = [rslt_knn2_tst, [Class_tst((tmp2+1):(tmp2+N_tst(i)),1), Prob_hat_tst(:,2)]];
                tmp1 = tmp1+N(i);
                tmp2 = tmp2+N_tst(i);
            end
        end
        Okay2{nei} = [Okay2{nei}; rslt_knn1_tst];
        Okay3{nei} = [Okay3{nei}; rslt_knn2_tst];
    end
end

save('d_272_our','Okay','Okay2','Okay3');

% 272 - Closed system

N = 100*ones(1,3);
N_tst = round(N/4);
B = [12,262,814,204,1338,170];
D = [2,10,10,10,10,10];
B = sum(B);
D = sum(D);

rep = 15;

k_nn = [1,3,9];
Okay = [];

for K = 1:fold
    
    y = [];
    y_tst = [];
    X = [];
    X_tst = [];
    
    tst = (indices == K);
    trn = ~tst;
    
    Class_trn = Class(trn,1);
    Features_trn = Features(trn,:);
    Class_tst = Class(tst,1);
    Features_tst = Features(tst,:);
    
    tmp1 = 0;
    for i=1:length(N)
        y{i} = Class_trn((tmp1+1):(tmp1+N(i)),1);
        tmp2 = 0;
        for k=1:length(B)
            X{1,k,i} = Features_trn((tmp1+1):(tmp1+N(i)),(tmp2+1):((tmp2+B(k))));
            tmp2 = tmp2+B(k);
        end
        tmp1 = tmp1+N(i);
    end
    
    tmp1 = 0;
    for i=1:length(N_tst)
        y_tst{i} = Class_tst((tmp1+1):(tmp1+N_tst(i)),1);
        tmp2 = 0;
        for k=1:length(B)
            X_tst{1,k,i} = Features_tst((tmp1+1):(tmp1+N_tst(i)),(tmp2+1):((tmp2+B(k))));
            tmp2 = tmp2+B(k);
        end
        tmp1 = tmp1+N_tst(i);
    end
    
    X{1} = X{1,1,1};
    X_tst{1} = X_tst{1,1,1};
    y{1} = y{1};
    y_tst{1} = y_tst{1};
    
    tmp = JH_Fun(X,X_tst,y,y_tst,N(1),B,D,rep,k_nn);
    Okay = [Okay;tmp];
end

save('d_272_closed1','Okay');

N = 100*ones(1,3);
N_tst = round(N/4);
B = [12,262,814,204,1338,170];
D = [2,10,10,10,10,10];
B = sum(B);
D = sum(D);

rep = 15;

k_nn = [1,3,9];
Okay = [];

for K = 1:fold
    
    y = [];
    y_tst = [];
    X = [];
    X_tst = [];
    
    tst = (indices == K);
    trn = ~tst;
    
    Class_trn = Class(trn,1);
    Features_trn = Features(trn,:);
    Class_tst = Class(tst,1);
    Features_tst = Features(tst,:);
    
    tmp1 = 0;
    for i=1:length(N)
        y{i} = Class_trn((tmp1+1):(tmp1+N(i)),1);
        tmp2 = 0;
        for k=1:length(B)
            X{1,k,i} = Features_trn((tmp1+1):(tmp1+N(i)),(tmp2+1):((tmp2+B(k))));
            tmp2 = tmp2+B(k);
        end
        tmp1 = tmp1+N(i);
    end
    
    tmp1 = 0;
    for i=1:length(N_tst)
        y_tst{i} = Class_tst((tmp1+1):(tmp1+N_tst(i)),1);
        tmp2 = 0;
        for k=1:length(B)
            X_tst{1,k,i} = Features_tst((tmp1+1):(tmp1+N_tst(i)),(tmp2+1):((tmp2+B(k))));
            tmp2 = tmp2+B(k);
        end
        tmp1 = tmp1+N_tst(i);
    end
    
    X{1} = X{1,1,2};
    X_tst{1} = X_tst{1,1,2};
    y{1} = y{2};
    y_tst{1} = y_tst{2};
    
    tmp = JH_Fun(X,X_tst,y,y_tst,N(2),B,D,rep,k_nn);
    Okay = [Okay;tmp];
end

save('d_272_closed2','Okay');

N = 100*ones(1,3);
N_tst = round(N/4);
B = [12,262,814,204,1338,170];
D = [2,10,10,10,10,10];
B = sum(B);
D = sum(D);

rep = 15;

k_nn = [1,3,9];
Okay = [];

for K = 1:fold
    
    y = [];
    y_tst = [];
    X = [];
    X_tst = [];
    
    tst = (indices == K);
    trn = ~tst;
    
    Class_trn = Class(trn,1);
    Features_trn = Features(trn,:);
    Class_tst = Class(tst,1);
    Features_tst = Features(tst,:);
    
    tmp1 = 0;
    for i=1:length(N)
        y{i} = Class_trn((tmp1+1):(tmp1+N(i)),1);
        tmp2 = 0;
        for k=1:length(B)
            X{1,k,i} = Features_trn((tmp1+1):(tmp1+N(i)),(tmp2+1):((tmp2+B(k))));
            tmp2 = tmp2+B(k);
        end
        tmp1 = tmp1+N(i);
    end
    
    tmp1 = 0;
    for i=1:length(N_tst)
        y_tst{i} = Class_tst((tmp1+1):(tmp1+N_tst(i)),1);
        tmp2 = 0;
        for k=1:length(B)
            X_tst{1,k,i} = Features_tst((tmp1+1):(tmp1+N_tst(i)),(tmp2+1):((tmp2+B(k))));
            tmp2 = tmp2+B(k);
        end
        tmp1 = tmp1+N_tst(i);
    end
    
    X{1} = X{1,1,3};
    X_tst{1} = X_tst{1,1,3};
    y{1} = y{3};
    y_tst{1} = y_tst{3};
    
    tmp = JH_Fun(X,X_tst,y,y_tst,N(3),B,D,rep,k_nn);
    Okay = [Okay;tmp];
    
end

save('d_272_closed3','Okay');

% 272 - Open system

N = 100*ones(1,3);
N_tst = round(N/4);
N = sum(N);
N_tst = sum(N_tst);
B = [12,262,814,204,1338,170];
D = [2,10,10,10,10,10];
B = sum(B);
D = sum(D);

rep = 15;

k_nn = [1,3,9];
Okay = [];

for K = 1:fold
    tst = (indices == K);
    trn = ~tst;
    
    Class_trn = Class(trn,1);
    Features_trn = Features(trn,:);
    Class_tst = Class(tst,1);
    Features_tst = Features(tst,:);
    
    tmp1 = 0;
    for i=1:length(N)
        y{i} = Class_trn((tmp1+1):(tmp1+N(i)),1);
        tmp2 = 0;
        for k=1:length(B)
            X{1,k,i} = Features_trn((tmp1+1):(tmp1+N(i)),(tmp2+1):((tmp2+B(k))));
            tmp2 = tmp2+B(k);
        end
        tmp1 = tmp1+N(i);
    end
    
    tmp1 = 0;
    for i=1:length(N_tst)
        y_tst{i} = Class_tst((tmp1+1):(tmp1+N_tst(i)),1);
        tmp2 = 0;
        for k=1:length(B)
            X_tst{1,k,i} = Features_tst((tmp1+1):(tmp1+N_tst(i)),(tmp2+1):((tmp2+B(k))));
            tmp2 = tmp2+B(k);
        end
        tmp1 = tmp1+N_tst(i);
    end
    tmp = JH_Fun(X,X_tst,y,y_tst,N,B,D,rep,k_nn);
    Okay = [Okay;tmp];
end

save('d_272_open','Okay')

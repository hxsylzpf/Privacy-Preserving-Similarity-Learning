R_s = [];
for i=1:length(N)
    for u=1:N(i)
        for v=1:N(i)
            if y{i}(u) == y{i}(v)
                R_s{i}(u,v) = 1;
            else
                R_s{i}(u,v) = -1;
            end
        end
    end
end

% If you want to utilize the random initial values
% 
% for k=1:length(D)
%     W{k} = normc(rand(B(k),D(k)));
% end
% 
% for i=1:length(N)
%     for k=1:length(D)
%         Z{1,k,i} = normc(rand(N(i),D(k)));
%     end
% end

for k=1:length(D)
    temp = [];
    for i=1:length(N)
        temp = [temp; X{1,k,i}];
    end
    [wei,sco] = pca(temp);
    W{k} = wei(:,1:D(k));
    sc{k} = sco(:,1:D(k));
end

tmp1 = 0;
for i=1:length(N)
    for k=1:length(D)
        Z{1,k,i} = sc{k}(tmp1+1:tmp1+N(i),:);
    end
    tmp1 = tmp1+N(i);
end

for k=1:length(D)
    W_old{k} = zeros(B(k),D(k));
    W_new{k} = zeros(B(k),D(k));
end

%% Derivatives of the objective function

e = 0.001;
eta = 0.001;
lamb = 0.5;

obj_val = [];

overtmp = 0;

while overtmp < rep
    for k=1:length(D)
        f_W_1 = 0;
        f_W_W_1 = 0;
        for i=1:length(N)
            f_W_1 = f_W_1 + 2*X{1,k,i}'*(X{1,k,i}*W{k}-Sign_app(Z{1,k,i},e));
            f_W_W_1 = f_W_W_1 + 2*X{1,k,i}'*X{1,k,i};
        end
        W_old{k} = W{k};
        W{k} = W{k} - pinv(f_W_W_1)*f_W_1;
        W_new{k} = W{k};
    end
    for i=1:length(N)
        for k=1:length(D)
            col_Z = Sign_app(Z{1,k,i},e);
            col_der_Z = Sign_der_app(Z{1,k,i},e);
            
            fir = [];
            for l=1:D(k)
                fir = [fir, R_s{i}.*(diag(col_der_Z(:,l))+repmat(col_der_Z(:,l),[1,N(i)]))*col_Z(:,l)];
            end
            f_W_2 = -2*(X{1,k,i}*W{k}-Sign_app(Z{1,k,i},e)).*Sign_der_app(Z{1,k,i},e) - 2*eta*fir + 2*lamb*Z{1,k,i};
            
            col_der2_Z = Sign_der2_app(Z{1,k,i},e);
            
            sec = [];
            for l=1:D(k)
                sec = [sec, R_s{i}.*(diag(col_der2_Z(:,l))+repmat(col_der2_Z(:,l),[1,N(i)]))*col_Z(:,l)];
            end
            
            thi = kron(eye(D(k)),R_s{i}.*(ones(N(i),N(i))+eye(N(i)))).*(reshape(col_der_Z,[N(i)*D(k),1])*reshape(col_der_Z,[N(i)*D(k),1])');
            
            fou = diag(reshape(-2*(X{1,k,i}*W{k}).*Sign_der2_app(Z{1,k,i},e) - 2*e*Plus_der2_app(Z{1,k,i},e), [N(i)*D(k),1]));
            
            f_W_W_2 = fou - 2*eta*(diag(reshape(sec,[N(i)*D(k),1]))+thi) + 2*lamb*eye(N(i)*D(k));
            
            Z{1,k,i} = Z{1,k,i} - reshape(pinv(f_W_W_2)*reshape(f_W_2,[N(i)*D(k),1]),[N(i),D(k)]);
        end
    end
    
    overtmp = overtmp + 1
    
    obj = 0;
    for k=1:length(D)
        for i=1:length(N)
            obj = obj + (sum(sum((X{1,k,i}*W{k}-Sign_app(Z{1,k,i},e)).^2)) - eta*trace(Z{1,k,i}'*R_s{i}*Z{1,k,i})); % + lamb*sum(sum(Z{1,k,i}.^2));
        end
    end
    
    obj_val = [obj_val, obj]
    
    %%  Test performance
    
    num_fix = 3; % (should be changed depending on the purpose)
    
    Z_total = cell(1,length(D),1);
    for o=1:length(D)
        for i=1:length(N)
            Z_total{1,o,1} = [Z_total{1,o,1}; sign(Z{1,o,i})];
        end
    end
    
    y_total = [];
    for i=1:length(N)
        y_total = [y_total; y{1,i}];
    end
    
    Z_tst_total = cell(1,length(D),1);
    for o=1:length(D)
        for i=1:length(N)
            Z_tst_total{1,o,1} = [Z_tst_total{1,o,1}; sign(X_tst{1,o,i}*W{o})];
        end
    end
    
    y_tst_total = [];
    for i=1:length(N)
        y_tst_total = [y_tst_total; y_tst{1,i}];
    end
    
    Z_grand = [];
    for o=1:length(D)
        Z_grand = [Z_grand, Z_total{1,o}];
    end
    
    Z_grand_tst = [];
    for o=1:length(D)
        Z_grand_tst = [Z_grand_tst, Z_tst_total{1,o}];
    end
    
    MDl = fitcknn(Z_grand,y_total,'NumNeighbors',num_fix,'Standardize',0,'Distance','hamming');
    [Class_hat_tst, Prob_hat_tst] = predict(MDl,Z_grand_tst);
    [accu, sensi, speci] = Correct(y_tst_total,Class_hat_tst);
    [~,~,~,auc] = perfcurve(y_tst_total,Prob_hat_tst(:,2),1);
    grand_knn_tst = [grand_knn_tst; [accu,sensi,speci,auc]]
    
end

Z_total = cell(1,length(D),1);
for o=1:length(D)
    for i=1:length(N)
        Z_total{1,o,1} = [Z_total{1,o,1}; sign(Z{1,o,i})];
    end
end

y_total = [];
for i=1:length(N)
    y_total = [y_total; y{1,i}];
end

Z_tst_total = cell(1,length(D),1);
for o=1:length(D)
    for i=1:length(N)
        Z_tst_total{1,o,1} = [Z_tst_total{1,o,1}; sign(X_tst{1,o,i}*W{o})];
    end
end

y_tst_total = [];
for i=1:length(N)
    y_tst_total = [y_tst_total; y_tst{1,i}];
end

Z_grand = [];
for o=1:length(D)
    Z_grand = [Z_grand, Z_total{1,o}];
end

Z_grand_tst = [];
for o=1:length(D)
    Z_grand_tst = [Z_grand_tst, Z_tst_total{1,o}];
end

for nei=1:length(k_nn)
    
    num = k_nn(nei);
    
    MDl = fitcknn(Z_grand,y_total,'NumNeighbors',num,'Standardize',0,'Distance','hamming');
    [Class_hat_tst, Prob_hat_tst] = predict(MDl,Z_grand_tst);
    
    Okay{nei} = [Okay{nei}; [y_tst_total, Prob_hat_tst(:,2)]];
end

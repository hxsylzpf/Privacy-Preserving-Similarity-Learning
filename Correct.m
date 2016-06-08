function [accu, sensi, speci, auc] = Correct( real, est )

corr = 0;
tp = 0;
tn = 0;
fp = 0;
fn = 0;

for i=1:length(est)
    if real(i) ~=  est(i)
        corr = corr+1; 
    end
end

for i=1:length(est)
    if real(i)==1&&est(i)==1
        tp = tp+1;    
    elseif real(i)==1&&est(i)==0
        fn = fn+1;
    elseif real(i)==0&&est(i)==0
        tn = tn+1;
    elseif real(i)==0&&est(i)==1
        fp = fp+1;
    end
end

accu = 1-(corr/length(est)); 
sensi = tp / (tp+fn);
speci = tn / (tn+fp);
auc = (sensi+speci)/2;

end


function T = BFMdecode(v, card)
for i=1:length(v)
    for k=1:length(card)
        T(i,k) = mod(v(i), card(k));
        v(i) = floor(v(i) ./card(k));
    end
end
end
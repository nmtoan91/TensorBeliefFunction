function r=testprecision(niteration, mark)
constant1 = .99;
constant2 = .90;
a=1; b=1;
for i=1:niteration
    if i <= mark
        a = a*constant1;
        b = b*(1-constant1);
    else
        a = a*(1-constant2);
        b = b*constant2;
    end
end
r=[a b];
fprintf('%.40f\n',r)
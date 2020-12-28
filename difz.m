function y=difz(x)
%computes all n(n-1)/2 differences from a nx1 vector

q=combnk(x,2);
y=q(:,1)-q(:,2);



end





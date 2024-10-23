function H=entropyMRS(P,b)
% H=entropyMRS(P,b)
% Calculate the entropy of a given memoryless random source with the
% probability distribution P.
% b is the base of the entropy (default: 2).
% If sum(P)~=1, then adjust the probability as P=P/sum(P).
% This corresponds to the case that each element of P denotes the number of
% occurrences of a symbol.
% Such a normalization process is also useful to overcome problems caused
% by quantization errors.
% All zero probabilities will be removed because they are singular.
% NOTE: The function is named "entropyMRS" because "entropy" has been used
% by another function in the Image Processing Toolbox.
% "MRS" is the abbreviation of "memoryless random source".
% Type "help entropy" for more information about another entropy function.

if nargin<1
    disp('At least one argument is needed!');
    return;
end

if nargin<2
    b=2;
end

% Allow the representation of the base e as 'e'.
if b(1)=='e'
    b=exp(1);
end

% Remove zero probabilities.
P(P==0)=[];

% Adjust P according to the value of sum(P).
if sum(P)~=1
    P=P/sum(P);
end

% Calculate the entropy to base 2.
H=-sum(P.*log2(P));

% Adjust the entropy according to the base.
if b~=2
    H=H/log2(b);
end

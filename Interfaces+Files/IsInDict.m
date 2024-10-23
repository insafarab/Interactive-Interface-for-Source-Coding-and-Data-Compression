function index=IsInDict(x,dict)
% index=IsInDict(x,dict)
% Find the index of x in a dictionary dict (a 1-D cell array).
% Return 0 if x is not in the dictionary.

n=numel(dict);
index=0;
for i=1:n
    if isequal(x,dict{i})
        index=i;
        break;
    end
end

function x=EntropyDecoder(y,code,LUT_n)
% x=EntropyDecoder(y,code)
% x=EntropyDecoder(y,code,LUT_n)
% An entropy decoder which work with encoded messages represented as both
% cell arrays and bitstreams.
% It checks the type of the encoded message y and invoke
% EntropyDecoder_Cell or EntropyDecoder_BS accordingly.

x=[];

if nargin<2
    disp('Two input arguments should be given as input of the funciton!');
    return;
end

if nargin<3
    LUT_n=13; % This is an optional argument of EntropyDecoder_Cell.
end

if iscell(y)
    x=EntropyDecoder_Cell(y,code,LUT_n);
else
    x=EntropyDecoder_BS(y,code);
end

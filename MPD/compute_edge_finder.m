function     [CloudData] = compute_edge_finder(CloudData,MPDUnfiltered)

x = MPDUnfiltered.backscatterRatio;

g = find_g(x);

CloudData.sobelOperator = g;

end

function [g] = find_g(x)

    %Create Sobel Operator
    gX = [1,2,1;0,0,0;-1,-2,-1]; gY = gX';
    %take x and y convolutions
    tempX = conv2(x,gX,'same');
    tempY = conv2(x,gY,'same');
    % find magnitude of 2d gradient from x and y
    g = sqrt(tempX.^2 + tempY.^2);
    
    %Fix data at the edges
    g(1,:)   = g(2,:);
    g(:,1)   = g(:,2);
    g(end,:) = g(end-1,:);
    g(:,end) = g(:,end-1);

end

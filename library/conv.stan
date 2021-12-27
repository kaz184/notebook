vector _conv(vector x, vector k, int N, int K) {
    vector[K] rev_k = reverse(k);
    vector[N] y;
    for(t in 1:N) y[t] = dot_product(x[max(1,t-K+1):t], rev_k[max(1,K-t+1):K]);
    return y;
}

vector conv(vector x, vector y) {
    int N = num_elements(x);
    int M = num_elements(y);
    return N > M ? _conv(x,y, N,M) : _conv(y,x, M,N);
}
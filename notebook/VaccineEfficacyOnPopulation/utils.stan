functions {
    vector conv_aux(vector x, vector y) {
        int T = num_elements(x);
        int K = num_elements(y);
        vector[T] z = zeros_vector(T);
        for(t in 1:T) for(s in 1:min(K,t)) {
            z[t] += x[t-s+1] * y[s];
        }
        return z;
    }

    vector conv(vector x, vector y) {
        return num_elements(x) > num_elements(y) ? conv_aux(x,y) : conv_aux(y,x);
    }

    real poisson_lpdf(vector k, vector lam) {
        return sum(k .* log(lam) - lam - lgamma(k+1));
    }

    vector ifelse(array[] int pred, vector tvalue, vector fvalue) {
        int N = num_elements(pred);
        vector[N] res;
        for(i in 1:N) res[i] = pred[i] ? tvalue[i] : fvalue[i];
        return res;
    }
}
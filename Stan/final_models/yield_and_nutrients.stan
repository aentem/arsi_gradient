data {
  // Dimensions
  int<lower=0> N;
  int<lower=0> K;
  
  // Variables
  vector[N] fert;
  vector[N] maom;
  vector[N] pom;
  vector[N] pH;
  vector[N] nf;
  vector[N] mid;
  vector[N] y;
}
transformed data {
  // Define standardized variables
  vector[N] fert_std;
  vector[N] maom_std;
  vector[N] pom_std;
  vector[N] pH_std;

  // Standardize variables
  fert_std = (fert - mean(fert)) / (2*sd(fert));
  maom_std = (maom - mean(maom)) / (2*sd(maom));
  pom_std = (pom - mean(pom)) / (2*sd(pom));
  pH_std = (pH - mean(pH)) / (2*sd(pH));
}
parameters  {
  // Define standardized parameters
  real alpha_std;
  vector[K] beta_std;
  real<lower=0> sigma_std;
}
model {
  // Uninformative priors
  alpha_std ~ normal(0,10);
  beta_std ~ normal(0,10);
  sigma_std ~ cauchy(0,5);

  // Run model
  y ~ lognormal(fert_std*beta_std[1] + maom_std*beta_std[2] + pom_std*beta_std[3] + pH_std*beta_std[4] + nf*beta_std[5] + mid*beta_std[6] + alpha_std,sigma_std);
}
generated quantities {
  // Generate natural parameters
  real beta_fert = beta_std[1] * sd(y) / sd(fert);
  real beta_maom = beta_std[2] * sd(y) / sd(maom);
  real beta_pom = beta_std[3] * sd(y) / sd(pom);
  real beta_pH = beta_std[4] * sd(y) / sd(pH);
  real beta_nf = beta_std[5];
  real beta_mid = beta_std[6];
  real<lower=0> sigma = sd(y) * sigma_std;

  // Predict data
  vector[N] y_tilde;
  for (n in 1:N)
    y_tilde[n] = lognormal_rng(fert_std[n]*beta_std[1] + maom_std[n]*beta_std[2] + pom_std[n]*beta_std[3] + pH_std[n]*beta_std[4] + nf[n]*beta_std[5] + mid[n]*beta_std[6] + alpha_std,sigma_std);
}

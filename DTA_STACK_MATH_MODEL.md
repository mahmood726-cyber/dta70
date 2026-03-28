
# DTA-Stack: Formal Mathematical Model Specification

## Tier 1: Penalized Likelihood (Firth)
For studies $i = 1 \dots N$, where data is extremely sparse:
$$ 	ext{logit}(\pi_{sens}) = \hat{\beta}_0 + \delta $$
$$ 	ext{logit}(\pi_{spec}) = \hat{\gamma}_0 + \delta $$
Where $\delta$ is a Firth penalty term (effectively $0.5$ in the logit space for bias reduction).

## Tier 2: Bivariate Hierarchical GLMM
Models the joint distribution of sensitivity and specificity:
$$ \begin{pmatrix} \mu_{i,sens} \ \mu_{i,spec} \end{pmatrix} \sim N \left( \begin{pmatrix} 	heta_{sens} \ 	heta_{spec} \end{pmatrix}, \Sigma ight) $$
where $\Sigma$ captures the between-study covariance $ho \sigma_{sens} \sigma_{spec}$.

## Tier 3: SROC-Informed Ensemble (The "Stack")
Weights studies based on their distance from the SROC operating curve:
$$ w_i = \frac{1}{1 + |D_i - (a + b S_i)|} $$
where $D_i$ is the log-diagnostic odds ratio and $S_i$ is the threshold proxy.
The pooled estimate is the weighted vector: $\bar{	heta} = \sum w_i 	heta_i$.

## Tier 4: Meta-Regression
Extends the model to covariates $X$:
$$ 	ext{logit}(\pi_{i,sens}) = \beta_0 + \beta_1 X_i + \epsilon_i $$
$$ 	ext{logit}(\pi_{i,spec}) = \gamma_0 + \gamma_1 X_i + \eta_i $$

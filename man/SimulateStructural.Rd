% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/simulations.R
\name{SimulateStructural}
\alias{SimulateStructural}
\title{Data simulation for Structural Causal Modelling}
\usage{
SimulateStructural(
  n = 100,
  pk = c(5, 5, 5),
  theta = NULL,
  n_manifest = NULL,
  nu_between = 0.5,
  v_between = c(0.5, 1),
  v_sign = c(-1, 1),
  continuous = TRUE,
  ev = 0.5,
  ev_manifest = 0.8,
  output_matrices = FALSE
)
}
\arguments{
\item{n}{number of observations in the simulated dataset.}

\item{pk}{vector of the number of (latent) variables per layer.}

\item{theta}{optional binary adjacency matrix of the Directed Acyclic Graph
(DAG) of causal relationships. This DAG must have a structure with layers
so that a variable can only be a parent of variable in one of the following
layers (see \code{\link{LayeredDAG}} for examples). The layers must be
provided in \code{pk}.}

\item{n_manifest}{vector of the number of manifest (observed) variables
measuring each of the latent variables. If \code{n_manifest=NULL}, there
are \code{sum(pk)} manifest variables and no latent variables. Otherwise,
there are \code{sum(pk)} latent variables and \code{sum(n_manifest)}
manifest variables. All entries of \code{n_manifest} must be strictly
positive.}

\item{nu_between}{probability of having an edge between two nodes belonging
to different layers, as defined in \code{pk}. If \code{length(pk)=1}, this
is the expected density of the graph.}

\item{v_between}{vector defining the (range of) nonzero path coefficients. If
\code{continuous=FALSE}, \code{v_between} is the set of possible values. If
\code{continuous=TRUE}, \code{v_between} is the range of possible values.}

\item{v_sign}{vector of possible signs for path coefficients. Possible inputs
are: \code{1} for positive coefficients, \code{-1} for negative
coefficients, or \code{c(-1, 1)} for both positive and negative
coefficients.}

\item{continuous}{logical indicating whether to sample path coefficients from
a uniform distribution between the minimum and maximum values in
\code{v_between} (if \code{continuous=FALSE}) or from proposed values in
\code{v_between} (if \code{continuous=FALSE}).}

\item{ev}{vector of proportions of variance in each of the (latent) variables
that can be explained by its parents. If there are no latent variables (if
\code{n_manifest=NULL}), these are the proportions of explained variances
in the manifest variables. Otherwise (if \code{n_manifest} is provided),
these are the proportions of explained variances in the latent variables.}

\item{ev_manifest}{vector of proportions of variance in each of the manifest
variable that can be explained by its latent parent. Only used if
\code{n_manifest} is provided.}

\item{output_matrices}{logical indicating if the true path coefficients,
residual variances, and precision and (partial) correlation matrices should
be included in the output.}
}
\value{
A list with: \item{data}{simulated data with \code{n} observations
  for manifest variables.} \item{theta}{adjacency matrix of the simulated
  Directed Acyclic Graph encoding causal relationships.}
  \item{Amat}{simulated (true) asymmetric matrix A in RAM notation. Only
  returned if \code{output_matrices=TRUE}.} \item{Smat}{simulated (true)
  symmetric matrix S in RAM notation. Only returned if
  \code{output_matrices=TRUE}.} \item{Fmat}{simulated (true) filter matrix F
  in RAM notation. Only returned if \code{output_matrices=TRUE}.}
  \item{sigma}{simulated (true) covariance matrix. Only returned if
  \code{output_matrices=TRUE}.}
}
\description{
Simulates data from a multivariate Normal distribution where relationships
between the variables correspond to a Structural Causal Model (SCM). To
ensure that the generated SCM is identifiable, the nodes are organised by
layers, with no causal effects within layers.
}
\examples{
\donttest{
# Simulation of a layered SCM
set.seed(1)
pk <- c(3, 5, 4)
simul <- SimulateStructural(n = 100, pk = pk)
print(simul)
summary(simul)
plot(simul)

# Choosing the proportions of explained variances for endogenous variables
set.seed(1)
simul <- SimulateStructural(
  n = 1000,
  pk = c(2, 3),
  nu_between = 1,
  ev = c(NA, NA, 0.5, 0.7, 0.9),
  output_matrices = TRUE
)

# Checking expected proportions of explained variances
1 - simul$Smat["x3", "x3"] / simul$sigma["x3", "x3"]
1 - simul$Smat["x4", "x4"] / simul$sigma["x4", "x4"]
1 - simul$Smat["x5", "x5"] / simul$sigma["x5", "x5"]

# Checking observed proportions of explained variances (R-squared)
summary(lm(simul$data[, 3] ~ simul$data[, which(simul$theta[, 3] != 0)]))
summary(lm(simul$data[, 4] ~ simul$data[, which(simul$theta[, 4] != 0)]))
summary(lm(simul$data[, 5] ~ simul$data[, which(simul$theta[, 5] != 0)]))

# Simulation including latent and manifest variables
set.seed(1)
simul <- SimulateStructural(
  n = 100,
  pk = c(2, 3),
  n_manifest = c(2, 3, 2, 1, 2)
)
plot(simul)

# Showing manifest variables in red
if (requireNamespace("igraph", quietly = TRUE)) {
  mygraph <- plot(simul)
  ids <- which(igraph::V(mygraph)$name \%in\% colnames(simul$data))
  igraph::V(mygraph)$color[ids] <- "red"
  igraph::V(mygraph)$frame.color[ids] <- "red"
  plot(mygraph)
}

# Choosing proportions of explained variances for latent and manifest variables
set.seed(1)
simul <- SimulateStructural(
  n = 100,
  pk = c(3, 2),
  n_manifest = c(2, 3, 2, 1, 2),
  ev = c(NA, NA, NA, 0.7, 0.9),
  ev_manifest = 0.8,
  output_matrices = TRUE
)
plot(simul)

# Checking expected proportions of explained variances
(simul$sigma_full["f4", "f4"] - simul$Smat["f4", "f4"]) / simul$sigma_full["f4", "f4"]
(simul$sigma_full["f5", "f5"] - simul$Smat["f5", "f5"]) / simul$sigma_full["f5", "f5"]
(simul$sigma_full["x1", "x1"] - simul$Smat["x1", "x1"]) / simul$sigma_full["x1", "x1"]
}
}
\references{
\insertRef{RegSEM}{fake}
}
\seealso{
\code{\link{SimulatePrecision}}, \code{\link{MakePositiveDefinite}},
  \code{\link{Contrast}}

Other simulation functions: 
\code{\link{SimulateAdjacency}()},
\code{\link{SimulateClustering}()},
\code{\link{SimulateComponents}()},
\code{\link{SimulateCorrelation}()},
\code{\link{SimulateGraphical}()},
\code{\link{SimulateRegression}()}
}
\concept{simulation functions}

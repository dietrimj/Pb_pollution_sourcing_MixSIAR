# From Jack Longman, based on his code from 5th Feb 2021 and Longman et al. (2018)
# 31st May 2021
# Script file to run Pb isotope mixture model, without GUI

################################################################################
# Pb isotope source provenance script (3 isotope ratios, no random effects)
# For samples from Hamilton, Ohio

library(MixSIAR)

# Load mix data
mix.filename <- system.file("extdata", "Hamilton_mixtures.csv", package = "MixSIAR")
mix <- load_mix_data(filename=mix.filename,
					 iso_names=c("Pb206Pb204","Pb207Pb204","Pb208Pb204"),
					 factors=c("Sample"),
					 fac_random=FALSE,
					 fac_nested=NULL,
					 cont_effects=NULL)

# Load source data
# Leaded gasoline values from Chow and Johnstone (1965), Rabinowitz and Wetherill (1972), Sherrell et al. (1992)
source.filename <- system.file("extdata", "Hamilton_sources.csv", package = "MixSIAR")
source <- load_source_data(filename=source.filename,
						   source_factors=NULL,
						   conc_dep=FALSE,
						   data_type="means",
						   mix)

# Load discrimination/TDF data
# Not necessary for Pb data so set all values of mean and sd to 0
discr.filename <- system.file("extdata", "Hamilton_discrimination.csv", package = "MixSIAR")
discr <- load_discr_data(filename=discr.filename, mix)

# Make isospace plot
plot_data(filename="isospace_plot",
	  plot_save_pdf=TRUE,
	  plot_save_png=FALSE,
		  mix,source,discr)

# Plot your prior
#plot_prior(alpha.prior=1,source) #uninformative/generalist prior

# Define model structure and write JAGS model file
model_filename <- "MixSIAR_model.txt"
resid_err <- FALSE
process_err <- TRUE
write_JAGS_model(model_filename, resid_err, process_err, mix, source)

# Run the JAGS model ("test" first, then "normal"), uninformative/generalist prior
jags.1 <- run_model(run="long", mix, source, discr, model_filename,alpha.prior=1)


# Process diagnostics, summary stats, and posterior plots
output_JAGS(jags.1, mix, source)

#summary(jags.1)

#Export your data to .csv file
require(R2jags)
attach.jags(jags.1)
write.csv(p.global, file="Hamilton_output_grouped model.csv")

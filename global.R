getOrUpdatePkg <- function(p, minVer, repo) {
  if (!isFALSE(try(packageVersion(p) < minVer, silent = TRUE) )) {
    if (missing(repo)) repo = c("predictiveecology.r-universe.dev", getOption("repos"))
    install.packages(p, repos = repo)
  }
}

getOrUpdatePkg("Require", "0.3.1.14")
getOrUpdatePkg("SpaDES.project", "0.0.8.9027")

################### RUNAME
setwd("~/GitHub")
.fast <- T

################ SPADES CALL
library(SpaDES.project)
out <- SpaDES.project::setupProject(
  runName = "BC_boreal",
  updateRprofile = TRUE,
  Restart = TRUE,
  paths = list(projectPath = runName,
               scratchPath = "~/scratch"),
  modules =
    file.path("PredictiveEcology",
              c("canClimateData@usePrepInputs",
                paste0(# development
                  c("Biomass_borealDataPrep",
                    "Biomass_core",
                    "Biomass_speciesData",
                    "Biomass_speciesFactorial",
                    "Biomass_speciesParameters",
                    "fireSense_IgnitionFit",
                    "fireSense_EscapeFit",
                    "fireSense_SpreadFit",
                    "fireSense_dataPrepFit",
                    "fireSense_dataPrepPredict",
                    "fireSense_IgnitionPredict",
                    "fireSense_EscapePredict",
                    "fireSense_SpreadPredict"),
                  "@development")
              )),
  options = list(spades.allowInitDuringSimInit = TRUE,
                 spades.allowSequentialCaching = F,
                 reproducible.showSimilar = TRUE,
                 reproducible.useMemoise = TRUE,
                 reproducible.memoisePersist = TRUE,
                 reproducible.cacheSaveFormat = "qs",
                 reproducible.inputPaths = "~/data",
                 # reproducible.inputPaths = "/mnt/e/linux/data",
                 LandR.assertions = FALSE,
                 reproducible.cacheSpeed = "fast",
                 reproducible.gdalwarp = TRUE,
                 reproducible.showSimilarDepth = 7,
                 gargle_oauth_cache = if (machine("W-VIC-A127585")) "~/.secret" else NULL,
                 gargle_oauth_email =
                   if (user("emcintir")) "eliotmcintire@gmail.com" else if (user("tmichele")) "tati.micheletti@gmail.com" else NULL,
                 SpaDES.project.fast = isTRUE(.fast),
                 spades.recoveryMode = 2,
                 spades.recoveryMode = FALSE
  ),
  params = list(
    fireSense_IgnitionFit = list(.plots = "screen",
                                 rescaleVars = TRUE,
                                 .useCache = c(".inputObjects", "init", "run")),
    fireSense_dataPrepFit = list(igAggFactor = 10),
    fireSense_EscapeFit = list(.useCache = c(".inputObjects", "init", "run")),
    .globals = list(.plots = NA,
                    .plotInitialTime = NA,
                    sppEquivCol = 'Boreal',
                    # cores = 9,
                    .useCache = c(".inputObjects", "init", "prepIgnitionFitData",
                                  "prepSpreadFitData", "prepEscapeFitData", "writeFactorialToDisk"))),
  times = list(start = 2011, end = 2025),
  studyArea = list(level = 2, NAME_2 = c("Peace River|Northern Rockies")), # NWT Conic Conformal
  studyAreaLarge = studyArea,
  require = c("reproducible", "SpaDES.core", "PredictiveEcology/LandR@development (>= 1.1.0.9073"),
  packages = c("googledrive", 'RCurl', 'XML',
               "PredictiveEcology/SpaDES.core@sequentialCaching (>= 2.0.3.9002)",
               "PredictiveEcology/reproducible@modsForLargeArchives (>= 2.0.10.9010)"),
  useGit = "sub"
)

if (SpaDES.project::user("emcintir"))
  SpaDES.project::pkgload2(
    list(file.path("~/GitHub", c("reproducible", "SpaDES.core", "SpaDES.tools", "LandR", "climateData", "fireSenseUtils",
                                 "PSPclean")),
         "~/GitHub/SpaDES.project"))
unlink(dir(tempdir(), recursive = TRUE, full.names = TRUE))
# undebug(reproducible:::.callArchiveExtractFn)
snippsim <- do.call(SpaDES.core::simInitAndSpades, out)



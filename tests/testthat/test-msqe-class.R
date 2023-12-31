# Checks for proper construction and get/setting QTLExperiment slots.
# library(QTLExperiment)
# library(testthat)
# source("setup.R")
# source("test-qtle-class.R")

context("QTLExperiment class")

test_that("construction of the QTLe works correctly - manual", {
    # With metadata explicitly provided
    qtle <- QTLExperiment(assays=list(betas=sumstats_noNames$betas,
                                     errors=sumstats_noNames$errors,
                                     pvalues=sumstats_noNames$pvalues,
                                     lfsrs=sumstats_noNames$pvalues),
                          state_id = state_ids,
                          feature_id = feature_ids,
                          variant_id = variant_ids)
    expect_equivalent(class(qtle), "QTLExperiment")
    expect_equivalent(assay(qtle, "betas"), sumstats_noNames$betas)
    expect_equivalent(assay(qtle, "errors"), sumstats_noNames$errors)
    expect_equivalent(assay(qtle, "pvalues"), sumstats_noNames$pvalues)
    expect_equivalent(assay(qtle, "lfsrs"), sumstats_noNames$pvalues)
    expect_equivalent(state_id(qtle), state_ids)
    expect_equivalent(feature_id(qtle), feature_ids)
    expect_equivalent(variant_id(qtle), variant_ids)

    # With metadata extracted from input data
    qtle <- QTLExperiment(assays=list(betas=sumstats$betas,
                                     errors=sumstats$errors,
                                     pvalues=sumstats$pvalues,
                                     lfsrs=sumstats$pvalues))
    expect_equivalent(class(qtle), "QTLExperiment")
    expect_equivalent(assay(qtle, "betas"), sumstats$betas)
    expect_equivalent(state_id(qtle), colnames(sumstats$betas))
})


test_that("construction of the QTLe works correctly - from se", {
    se <- SummarizedExperiment(assays=list(betas=sumstats$betas,
                                           errors=sumstats$errors))
    qtle <- as(se, "QTLExperiment")

    expect_equivalent(class(qtle), "QTLExperiment")
    expect_equivalent(assay(qtle, "betas"), sumstats$betas)
    expect_equivalent(assay(qtle, "errors"), sumstats$errors)
})


test_that("QTLe valid check works correctly", {

    expect_error(QTLExperiment(assays=list(errors=sumstats$errors,
                                          pvalues=sumstats$pvalues,
                                          lfsrs=sumstats$pvalues),
                               state_id = state_ids,
                               feature_id=feature_ids,
                               variant_id=variant_ids),
                 "betas: assay needed")

    expect_error(QTLExperiment(assays=list(betas=sumstats$betas,
                                          pvalues=sumstats$pvalues,
                                          lfsrs=sumstats$pvalues),
                               state_id = state_ids,
                               feature_id=feature_ids,
                               variant_id=variant_ids),
                 "errors: assay needed")
})


test_that("QTLe feature IDs are provided or pulled from rownames of betas", {

    qtle2 <- QTLExperiment(assays=list(betas=sumstats$betas,
                                      errors=sumstats$errors,
                                      pvalues=sumstats$pvalues,
                                      lfsrs=sumstats$pvalues),
                           feature_id=feature_ids, variant_id=variant_ids)
    expect_equivalent(state_id(qtle2), state_ids,
                      colnames(sumstats$betas), colnames(qtle2),
                      colnames(betas(qtle2)), colnames(assay(qtle2, "lfsr")))


    expect_equivalent(feature_id(qtle2), feature_ids,
                      rowData(qtle2)$feature_id,
                      gsub("\\|.*", "", row.names(betas(qtle2))))

    expect_equivalent(variant_id(qtle2), variant_ids,
                      rowData(qtle2)$variant_id,
                      gsub(".*\\|", "", row.names(betas(qtle2))))
})

test_that("QTLE metadata ID checks are working", {
    expect_error(QTLExperiment(assays=list(betas=sumstats_noNames$betas,
                                          errors=sumstats_noNames$errors),
                               state_id = state_ids, variant_id=variant_ids),
                 "Feature/variant IDs should be provided as pipe separated string
             in rownames or using feature_id={...} and variant_id={...}.",
                 fixed=TRUE)

    expect_error(QTLExperiment(assays=list(betas=sumstats_noNames$betas,
                                          errors=sumstats_noNames$errors),
                               state_id = state_ids,
                               feature_id=feature_ids),
                 "Feature/variant IDs should be provided as pipe separated string
             in rownames or using feature_id={...} and variant_id={...}.",
                 fixed=TRUE)


    expect_error(QTLExperiment(assays=list(betas=sumstats_noNames$betas,
                                          errors=sumstats_noNames$errors),
                               feature_id=feature_ids,
                               variant_id=variant_ids),
                 "State IDs should be provided as colnames or state_id={...}.",
                 fixed=TRUE)
})



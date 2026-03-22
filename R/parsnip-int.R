#' PerpetualBooster via parsnip
#'
#' A parsnip-compatible model specification for the PerpetualBooster algorithm.
#' Perpetual is a self-generalizing gradient boosting machine that requires no
#' hyperparameter optimization — it automatically finds the best configuration
#' given a computational `budget`. Supports classification, regression, and
#' censored regression modes.
#'
#' @param mode A string for the model mode. One of `"classification"`,
#'   `"regression"`, or `"censored regression"`. Defaults to
#'   `"classification"`.
#' @param engine A string for the computational engine. Currently only
#'   `"perpetual"`. Defaults to `"perpetual"`.
#' @param objective A string specifying the loss function.
#'   - Classification: `"LogLoss"` (default).
#'   - Regression: `"SquaredLoss"` (default).
#'   - Censored regression: `"SurvivalLogLikelihood"` (default).
#' @param budget A numeric value (0–1) controlling how much of the
#'   self-generalization budget to spend. Higher values allow more iterations
#'   and typically yield better models at the cost of longer training time.
#'   `NULL` uses the algorithm's internal default.
#' @param iteration_limit An integer upper bound on the number of boosting
#'   iterations. `NULL` means no explicit limit (budget governs stopping).
#' @param stopping_rounds An integer for early stopping: training halts if the
#'   validation metric does not improve for this many consecutive rounds.
#'   `NULL` disables early stopping.
#' @param max_bin An integer controlling the maximum number of histogram bins
#'   used when discretising continuous features. Larger values may improve
#'   accuracy but increase memory usage. `NULL` uses the default.
#' @param num_threads An integer specifying the number of parallel threads.
#'   `NULL` uses all available cores.
#' @param missing The value to treat as missing data. Defaults to `NaN`
#'   when `NULL`.
#' @param allow_missing_splits A logical. If `TRUE`, splits on features with
#'   missing values are permitted.
#' @param create_missing_branch A logical. If `TRUE`, a dedicated branch is
#'   created for missing values (producing ternary trees rather than binary
#'   trees).
#' @param missing_node_treatment A string controlling how weights are assigned
#'   to missing-value nodes when `create_missing_branch = TRUE`. One of
#'   `"None"`, `"AssignToParent"`, `"AverageLeafWeight"`, or
#'   `"AverageNodeWeight"`.
#' @param log_iterations An integer. If positive, training progress is printed
#'   every this many iterations.
#' @param quantile A numeric value in (0, 1) used when `objective` is a
#'   quantile-regression loss.
#' @param reset A logical. If `TRUE`, the booster is re-initialised before
#'   fitting (relevant for incremental training).
#' @param timeout A numeric value (seconds). Training stops after this wall-
#'   clock time even if `budget` or `iteration_limit` has not been reached.
#' @param memory_limit A numeric value (GB). Training stops if resident memory
#'   usage exceeds this threshold.
#' @param seed An integer random seed for reproducibility.
#' @param calibration_method A string specifying the method used to generate
#'   prediction intervals (`type = "interval"` in `predict()`). One of
#'   `"WeightVariance"`, `"MinMax"`, `"GRP"`, or `"Conformal"`.
#' @param save_node_stats A logical. If `TRUE`, per-node statistics are stored
#'   in the model object. Required for certain calibration methods and
#'   importance types.
#'
#' @return A \code{model_spec} object of class \code{perpsnip}.
#'
#' @examples
#' \dontrun{
#' library(perpsnip)
#' library(workflows)
#'
#' spec = perpsnip(mode = "classification", budget = 0.5)
#'
#' wf = workflow() |>
#'   add_formula(am ~ .) |>
#'   add_model(spec) |>
#'   fit(data = dplyr::mutate(mtcars, am = as.factor(am)))
#' }
#'
#' @export
perpsnip = function(
        mode = "classification",
        engine = "perpetual",
        objective = NULL,
        budget = NULL,
        iteration_limit = NULL,
        stopping_rounds = NULL,
        max_bin = NULL,
        num_threads = NULL,
        missing = NULL,
        allow_missing_splits = NULL,
        create_missing_branch = NULL,
        missing_node_treatment = NULL,
        log_iterations = NULL,
        quantile = NULL,
        reset = NULL,
        timeout = NULL,
        memory_limit = NULL,
        seed = NULL,
        calibration_method = NULL,
        save_node_stats = NULL
) {
    mode = rlang::arg_match(
        mode,
        c("classification", "regression", "censored regression")
    )

    args = list(
        objective = rlang::enquo(objective),
        budget = rlang::enquo(budget),
        iteration_limit = rlang::enquo(iteration_limit),
        stopping_rounds = rlang::enquo(stopping_rounds),
        max_bin = rlang::enquo(max_bin),
        num_threads = rlang::enquo(num_threads),
        missing = rlang::enquo(missing),
        allow_missing_splits = rlang::enquo(allow_missing_splits),
        create_missing_branch = rlang::enquo(create_missing_branch),
        missing_node_treatment = rlang::enquo(missing_node_treatment),
        log_iterations = rlang::enquo(log_iterations),
        quantile = rlang::enquo(quantile),
        reset = rlang::enquo(reset),
        timeout = rlang::enquo(timeout),
        memory_limit = rlang::enquo(memory_limit),
        seed = rlang::enquo(seed),
        calibration_method = rlang::enquo(calibration_method),
        save_node_stats = rlang::enquo(save_node_stats)
    )

    parsnip::new_model_spec(
        cls = "perpsnip",
        args = args,
        eng_args = NULL,
        mode = mode,
        user_specified_mode = !missing(mode),
        method = NULL,
        engine = engine,
        user_specified_engine = !missing(engine)
    )
}


#' @keywords internal
#' @export
print.perpsnip = function(x, ...) {
    cat("Perpetual Boosting Model Specification (", x$mode, ")\n\n", sep = "")
    parsnip::model_printer(x, ...)
    invisible(x)
}

#' @importFrom stats update
#' @keywords internal
#' @export
update.perpsnip = function(
        object,
        parameters = NULL,
        objective = NULL,
        budget = NULL,
        iteration_limit = NULL,
        stopping_rounds = NULL,
        max_bin = NULL,
        num_threads = NULL,
        missing = NULL,
        allow_missing_splits = NULL,
        create_missing_branch = NULL,
        missing_node_treatment = NULL,
        log_iterations = NULL,
        quantile = NULL,
        reset = NULL,
        timeout = NULL,
        memory_limit = NULL,
        seed = NULL,
        calibration_method = NULL,
        save_node_stats = NULL,
        fresh = FALSE,
        ...
) {
    args = list(
        objective = rlang::enquo(objective),
        budget = rlang::enquo(budget),
        iteration_limit = rlang::enquo(iteration_limit),
        stopping_rounds = rlang::enquo(stopping_rounds),
        max_bin = rlang::enquo(max_bin),
        num_threads = rlang::enquo(num_threads),
        missing = rlang::enquo(missing),
        allow_missing_splits = rlang::enquo(allow_missing_splits),
        create_missing_branch = rlang::enquo(create_missing_branch),
        missing_node_treatment = rlang::enquo(missing_node_treatment),
        log_iterations = rlang::enquo(log_iterations),
        quantile = rlang::enquo(quantile),
        reset = rlang::enquo(reset),
        timeout = rlang::enquo(timeout),
        memory_limit = rlang::enquo(memory_limit),
        seed = rlang::enquo(seed),
        calibration_method = rlang::enquo(calibration_method),
        save_node_stats = rlang::enquo(save_node_stats)
    )

    parsnip::update_spec(
        object = object,
        parameters = parameters,
        args_enquo_list = args,
        fresh = fresh,
        cls = "perpsnip"
    )
}

#' @keywords internal
#' @noRd
#' @export
perpetual_class = function(x, y, objective = "LogLoss", ...) {
    if (!is.factor(y) ) {
        stop("`y` must be a factor for classification.", call. = FALSE)
    }

    lvls = levels(y)
    y_num = as.integer(y) - 1L

    model = perpetual::perpetual(x = x, y = y_num, objective = objective, ...)

    attr(model, "classes") = lvls
    model
}

#' @keywords internal
#' @noRd
perpetual_prob_convert = function(out, object) {
    classes = as.character(attr(object$fit, "classes"))

    if (is.null(classes) || length(classes) == 0) {
        classes = c("0", "1")
    }

    res = if (is.matrix(out)) {
        as.data.frame(out)
    } else {
        data.frame(
            p0 = 1 - out,
            p1 = out,
            check.names = FALSE
        )
    }
    colnames(res) = classes

    tibble::as_tibble(res)
}

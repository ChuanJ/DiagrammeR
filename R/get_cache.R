#' Get a cached vector from a graph object
#' @description Get the vector cached in a graph object
#' of class \code{dgr_graph}.
#' @param graph a graph object of class
#' \code{dgr_graph}.
#' @param name the name of the object to extract from
#' the cache. If none supplied, the most recent object
#' added to the cache will be returned.
#' @return a vector.
#' @examples
#' # Set a seed
#' set.seed(23)
#'
#' # Create a graph with 5 nodes and 5 edges
#' graph <-
#'   create_graph() %>%
#'   add_n_nodes(n = 5) %>%
#'   set_node_attrs(
#'     node_attr = "value",
#'     values = rnorm(node_count(.), 8, 2)) %>%
#'   add_edges_w_string(
#'     edges = "1->2 1->3 2->4 2->5 3->2")
#'
#' # Cache all values from the node attribute `value`
#' # as a numeric vector
#' graph <-
#'   graph %>%
#'   cache_node_attrs(
#'     node_attr = "value",
#'     mode = "numeric")
#'
#' # Return the cached vector
#' graph %>%
#'   get_cache()
#' #> [1] 9.993210 10.214981  7.443827
#' #> [4] 10.038411  8.090874
#' @export get_cache

get_cache <- function(graph,
                      name = NULL) {

  # Validation: Graph object is valid
  if (graph_object_valid(graph) == FALSE) {
    stop("The graph object is not valid.")
  }

  # If there is no cached vector available, return NA
  if (length(graph$cache) == 0) {
    return(NA)
  }

  if (is.null(name)) {
    return(graph$cache[[length(graph$cache)]])
  } else {
    return(graph$cache[[name]])
  }
}

#' Add a cycle of nodes to the graph
#' @description With a graph object of class
#' \code{dgr_graph}, add a node cycle to the graph.
#' @param graph a graph object of class
#' \code{dgr_graph}.
#' @param n the number of nodes comprising the cycle.
#' @param type an optional string that describes the
#' entity type for the nodes to be added.
#' @param label either a vector object of length
#' \code{n} that provides optional labels for the new
#' nodes, or, a boolean value where setting to
#' \code{TRUE} ascribes node IDs to the label and
#' \code{FALSE} yields a blank label.
#' @param rel an optional string for providing a
#' relationship label to all new edges created in the
#' node cycle.
#' @param ... optional node attributes supplied as
#' vectors.
#' @return a graph object of class \code{dgr_graph}.
#' @examples
#' # Create a new graph and add a cycle of nodes to it
#' graph <-
#'   create_graph() %>%
#'   add_cycle(n = 6)
#'
#' # Get node information from this graph
#' node_info(graph)
#' #>   id type label deg indeg outdeg loops
#' #> 1  1 <NA>     1   2     1      1     0
#' #> 2  2 <NA>     2   2     1      1     0
#' #> 3  3 <NA>     3   2     1      1     0
#' #> 4  4 <NA>     4   2     1      1     0
#' #> 5  5 <NA>     5   2     1      1     0
#' #> 6  6 <NA>     6   2     1      1     0
#' @importFrom dplyr select bind_cols
#' @importFrom tibble as_tibble
#' @export add_cycle

add_cycle <- function(graph,
                      n,
                      type = NULL,
                      label = TRUE,
                      rel = NULL,
                      ...) {

  # Get the time of function start
  time_function_start <- Sys.time()

  # Validation: Graph object is valid
  if (graph_object_valid(graph) == FALSE) {
    stop("The graph object is not valid.")
  }

  # Stop if n is too small
  if (n <= 2)  {
    stop("The value for n must be at least 3.")
  }

  # Create bindings for specific variables
  id <- index__ <- NULL

  # Get the number of nodes ever created for
  # this graph
  nodes_created <- graph$last_node

  # Get the number of edges ever created for
  # this graph
  edges_created <- graph$last_edge

  # Get the graph's global attributes
  global_attrs <- graph$global_attrs

  # Get the graph's log
  graph_log <- graph$graph_log

  # Get the graph's info
  graph_info <- graph$graph_info

  # Get the sequence of nodes required
  nodes <- seq(1, n)

  # Collect extra vectors of data as `extras`
  extras <- list(...)

  if (length(extras) > 0) {

    extras_tbl <- tibble::as_tibble(extras)

    if (nrow(extras_tbl) < n) {

      extras$index__ <- 1:n

      extras_tbl <-
        tibble::as_tibble(extras) %>%
        dplyr::select(-index__)
    }

    if ("id" %in% colnames(extras_tbl)) {
      extras_tbl <-
        extras_tbl %>%
        dplyr::select(-id)
    }
  }

  # Create a node data frame for the tree graph
  cycle_nodes <-
    create_node_df(
      n = n,
      type = type,
      label = label)

  # Add extra columns if available
  if (exists("extras_tbl")) {

    cycle_nodes <-
      cycle_nodes %>%
      dplyr::bind_cols(extras_tbl)
  }

  # Create an edge data frame for the cycle graph
  cycle_edges <-
    create_edge_df(
      from = nodes,
      to = c(nodes[2:length(nodes)], nodes[1]),
      rel = rel)

  # Create the cycle graph
  cycle_graph <- create_graph(cycle_nodes, cycle_edges)

  # If the input graph is not empty, combine graphs
  # using the `combine_graphs()` function
  if (!is_graph_empty(graph)) {

    combined_graph <- combine_graphs(graph, cycle_graph)

    # Update the `last_node` counter
    combined_graph$last_node <- nodes_created + nrow(cycle_nodes)

    # Update the `last_edge` counter
    combined_graph$last_edge <- edges_created + nrow(cycle_edges)

    # Update the `graph_log` df with an action
    graph_log <-
      add_action_to_log(
        graph_log = graph_log,
        version_id = nrow(graph_log) + 1,
        function_used = "add_cycle",
        time_modified = time_function_start,
        duration = graph_function_duration(time_function_start),
        nodes = nrow(combined_graph$nodes_df),
        edges = nrow(combined_graph$edges_df))

    combined_graph$global_attrs <- global_attrs
    combined_graph$graph_log <- graph_log
    combined_graph$graph_info <- graph_info

    # Write graph backup if the option is set
    if (combined_graph$graph_info$write_backups) {
      save_graph_as_rds(graph = combined_graph)
    }

    return(combined_graph)
  } else {

    # Update the `graph_log` df with an action
    graph_log <-
      add_action_to_log(
        graph_log = graph_log,
        version_id = nrow(graph_log) + 1,
        function_used = "add_cycle",
        time_modified = time_function_start,
        duration = graph_function_duration(time_function_start),
        nodes = nrow(cycle_graph$nodes_df),
        edges = nrow(cycle_graph$edges_df))

    cycle_graph$global_attrs <- global_attrs
    cycle_graph$graph_log <- graph_log
    cycle_graph$graph_info <- graph_info

    # Write graph backup if the option is set
    if (cycle_graph$graph_info$write_backups) {
      save_graph_as_rds(graph = cycle_graph)
    }

    return(cycle_graph)
  }
}

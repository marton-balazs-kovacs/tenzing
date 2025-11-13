# Load and merge validation configuration

This function loads a base configuration and merges it with a specific
configuration file, allowing for inheritance and reduced duplication.
Includes caching to improve performance.

## Usage

``` r
load_validation_config(config_path, base_config_path = NULL, use_cache = TRUE)
```

## Arguments

- config_path:

  Path to the specific configuration file

- base_config_path:

  Path to the base configuration file (optional)

- use_cache:

  Whether to use caching (default: TRUE)

## Value

Merged configuration list

import mudata
import scanpy as sc
import logging
from sys import stdout
import pandas as pd
from pathlib import Path

# set logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)
console_handler = logging.StreamHandler(stdout)
logFormatter = logging.Formatter("%(asctime)s %(levelname)-8s %(message)s")
console_handler.setFormatter(logFormatter)
logger.addHandler(console_handler)

## VIASH START
par = {
  "input": "resources_test/10x_5k_anticmv/processed/10x_5k_anticmv.cellranger_multi.output.output",
  "use_raw": True,
  "uns_metrics": "metrics_cellranger",
  "output": "foo.h5mu",
  "min_genes": 100,
  "min_counts": 1000
}
## VIASH END

# TODO: add support for cell multiplexing

# processing counts
count_raw = Path(par["input"]) / "multi" / "count" / "raw_feature_bc_matrix.h5"
if count_raw.exists:
  logger.info("Reading %s.", count_raw)
  adata = sc.read_10x_h5(count_raw, gex_only=False)

  # set the gene ids as var_names
  logger.info("Renaming var columns")
  adata.var = adata.var\
    .rename_axis("gene_symbol")\
    .reset_index()\
    .set_index("gene_ids")

# parse metrics summary file and store in .obsm or .obs
if par["input_metrics_summary"] and par["uns_metrics"]:
  logger.info("Reading metrics summary file '%s'", par['input_metrics_summary'])

  def read_percentage(val):
      try:
          return float(val.strip('%')) / 100
      except AttributeError:
          return val

  metrics_summary = pd.read_csv(par["input_metrics_summary"], decimal=".", quotechar='"', thousands=",").applymap(read_percentage)

  logger.info("Storing metrics summary in .uns['%s']", par['uns_metrics'])
  adata.uns[par["uns_metrics"]] = metrics_summary
else:
  is_none = "input_metrics_summary" if not par["input_metrics_summary"] else "uns_metrics"
  logger.info("Not storing metrics summary because par['%s'] is None", is_none)

# might perform basic filtering to get rid of some data
# applicable when starting from the raw counts
if par["min_genes"]:
  logger.info("Filtering with min_genes=%d", par['min_genes'])
  sc.pp.filter_cells(adata, min_genes=par["min_genes"])

if par["min_counts"]:
  logger.info("Filtering with min_counts=%d", par['min_counts'])
  sc.pp.filter_cells(adata, min_counts=par["min_counts"])

# generate output
logger.info("Convert to mudata")
mdata = mudata.MuData(adata)

# override root .obs
mdata.obs = adata.obs

# write output
logger.info("Writing %s", par["output"])
mdata.write_h5mu(par["output"])

import subprocess
from os import path
import muon as mu
import numpy as np

## VIASH START
meta = {
    'functionality_name': 'lognorm',
    'resources_dir': 'resources_test/'
}
## VIASH END

input = f"{meta['resources_dir']}/pbmc_1k_protein_v3/pbmc_1k_protein_v3_filtered_feature_bc_matrix.h5mu"
output = "output.h5mu"

cmd_pars = [
    f"./{meta['functionality_name']}",
    "--input", input,
    "--output", output,
]
out = subprocess.check_output(cmd_pars).decode("utf-8")

print("> Check if output was created.")
assert path.exists(output), "No output was created."

print("> Reading mudata files.")
mu_input = mu.read_h5mu(input)
mu_output = mu.read_h5mu(output)

print("> Check whether output contains right modalities.")
assert "rna" in mu_output.mod, 'Output should contain data.mod["prot"].'
assert "prot" in mu_output.mod, 'Output should contain data.mod["prot"].'

rna_in = mu_input.mod["rna"]
rna_out = mu_output.mod["rna"]
prot_in = mu_input.mod["prot"]
prot_out = mu_output.mod["prot"]

print("> Check shape of outputs.")
assert rna_in.shape == rna_out.shape, "Should have same shape as before"
assert prot_in.shape == prot_out.shape, "Should have same shape as before"

print("> Check if expression has changed.")
assert np.mean(rna_in.X) != np.mean(rna_out.X), "Expression should have changed"

print("> Checking row-wise and column-wise correlation.")
nz_row, nz_col = rna_in.X.nonzero()
row_corr = np.corrcoef(rna_in.X[nz_row[0],:].toarray().flatten(), rna_out.X[nz_row[0],:].toarray().flatten())[0,1]
col_corr = np.corrcoef(rna_in.X[:,nz_col[0]].toarray().flatten(), rna_out.X[:,nz_col[0]].toarray().flatten())[0,1]
assert row_corr > .1
assert col_corr > .1

print(">> All tests succeeded!")
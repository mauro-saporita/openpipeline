
import pytest
from pathlib import Path
from mudata import read_h5mu
import sys
import numpy as np
## VIASH START
meta = {
    'executable': 'target/docker/transform/clr/clr',
    'resources_dir': './resources_test/',
    'cpus': 2,
    'config': "./src/transform/clr/config.vsh.yaml"
}


## VIASH END

resources_dir = meta["resources_dir"]
input_file = f"{resources_dir}/pbmc_1k_protein_v3/pbmc_1k_protein_v3_filtered_feature_bc_matrix.h5mu"



def test_clr(run_component):
    run_component([
        "--input", input_file,
        "--output", "foo.h5mu",
        "--output_compression", "gzip",
        "--output_layer", "clr"
    ])
    assert Path("foo.h5mu").is_file()
    output_h5mu = read_h5mu("foo.h5mu")
    assert 'clr' in output_h5mu.mod['prot'].layers.keys()
    assert output_h5mu.mod['prot'].layers['clr'] is not None

def test_clr_output_to_x(run_component):
    original_x = read_h5mu(input_file).mod['prot'].X
    run_component([
        "--input", input_file,
        "--output", "foo.h5mu",
        "--output_compression", "gzip",
    ])
    assert Path("foo.h5mu").is_file()
    output_h5mu = read_h5mu("foo.h5mu")
    assert 'clr' not in output_h5mu.mod['prot'].layers
    assert not np.all(np.isclose(original_x.toarray(), 
                                 output_h5mu.mod['prot'].X.toarray(), 
                                 rtol=1e-07, atol=1e-07))


if __name__ == '__main__':
    sys.exit(pytest.main([__file__]))
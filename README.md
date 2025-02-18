# DepMap Download Snakemake Pipeline

This pipeline is a template for depmap pipelines. 

It currently downloads data from the DepMap portal for the `Sanger Drug Combinations 2022` Release

## Running the pipeline
```console
pixi install
pixi run snakemake 
```

Will download all the data to `rawdata/Sanger Drug Combinations 2022`
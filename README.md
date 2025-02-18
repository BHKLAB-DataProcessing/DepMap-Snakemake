# DepMap Download Snakemake Pipeline

This pipeline is a template for depmap pipelines. 

It currently downloads data from the DepMap portal for the `Sanger Drug Combinations 2022` Release



## Cleaning up the data 

```console
pixi clean
```


## Running the pipeline

```console
pixi install
pixi run snake
```
Will download all the data to `rawdata/Sanger Drug Combinations 2022`



If things arent working:
```console
pixi clean && pixi clean cache -y
pixi install
```
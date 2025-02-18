import pandas as pd
from pathlib import Path
import requests
import shutil
RAWDATA = Path("rawdata")
PROCDATA = Path("procdata")
RELEASE_NAME = "Sanger Drug Combinations 2022".replace(" ", "_")

depmap_db = (
    pd.read_csv("https://depmap.org/portal/api/download/files")
    .query("release == 'Sanger Drug Combinations 2022'")
    .reset_index(drop=True)
)



def get_release_files(wildcards):
    return [
        RAWDATA / wildcards.release / file
        for file in depmap_db["filename"].tolist()
    ]

rule all:
  input:
    rawdata = PROCDATA / RELEASE_NAME

rule download_Release:
  input:
    unpack(get_release_files)
  output:
    dir = directory(PROCDATA / "{release}")
  shell:
    """
    mkdir -p "{output.dir}"
    ls "rawdata/{wildcards.release}" -1 > "{output.dir}"/files.txt
    """

rule download_file:
  output:
    download_file = RAWDATA / "{release}" / "{file}"
  retries: 3
  run:
    baseurl = "https://depmap.org/portal/download/api/download"
    params = {
      "file_name": f"sanger-drug-drug-interactions-9406.9/{wildcards.file}",
      "bucket": "depmap-external-downloads"
    }
    result = requests.get(baseurl, params=params, stream=True)
    with open(output.download_file, "wb") as f:
        shutil.copyfileobj(result.raw, f)


rule clean:
  shell:
    "rm -rf rawdata procdata"
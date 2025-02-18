import pandas as pd
from pathlib import Path
import requests
RAWDATA = Path("rawdata")
PROCDATA = Path("procdata")
RELEASE_NAME = "Sanger Drug Combinations 2022"

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
    base_url = "https://depmap.org/portal/data_page/?tab=allData&releasename="
    url = f"{base_url}{wildcards.release}&filename={wildcards.file}"
    with requests.get(url) as r:
        r.raise_for_status()
        with open(output.download_file, "wb") as f:
            f.write(r.content)


rule clean:
  shell:
    "rm -rf rawdata procdata"
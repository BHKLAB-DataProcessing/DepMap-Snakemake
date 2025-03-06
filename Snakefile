import pandas as pd
from pathlib import Path
import requests
import shutil
RAWDATA = Path("rawdata")
PROCDATA = Path("procdata")
LOGS = Path("logs")
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
  run:
    Path(output.dir).mkdir(parents=True, exist_ok=True)
    with open(f"{output.dir}/files.txt", "w") as f:
        for file in get_release_files(wildcards):
            f.write(f"{file}\n")

rule download_file:
  output:
    download_file = RAWDATA / "{release}" / "{file}"
  log:
    error = LOGS / "{release}" / "{file}.error.log"
  run:
    import requests
    import shutil
    import time
    
    # Create log directory
    Path(log.error).parent.mkdir(parents=True, exist_ok=True)

    baseurl = "https://depmap.org/portal/download/api/download"
    params = {
      "file_name": f"sanger-drug-drug-interactions-9406.9/{wildcards.file}",
      "bucket": "depmap-external-downloads"
    }

    try:
        result = requests.get(baseurl, params=params, stream=True, timeout=30)
        result.raise_for_status()
        with open(log.error, "w") as f:
            f.write(f'Getting URL: {result.url}\n')
        with open(output.download_file, "wb") as f:
            shutil.copyfileobj(result.raw, f)
        with open(log.error, "w") as f:
            f.write("Download successful\n")
    except requests.exceptions.RequestException as e:
        error_msg = f"Download failed: {e}\n"
        with open(log.error, "a") as f:
            f.write(error_msg)
        raise e

rule clean:
  shell:
    "rm -rf rawdata procdata logs"
## Lopez, Naylor, and Jones (2025) replication code and data
This repository contains all code and data used in Lopez, Naylor, and Jones (2025), "*The role of development institutions in advancing sustainable irrigation*," manuscript submitted and currently under peer review.


### Overview
The repository is structured into two main directories—`irrigation investments` and `impact evaluations`—which mirror the organization of the paper. Each of these directories contains a series of numbered sub-folders that reflect the sequential steps taken in cleaning, processing, and analyzing the data.


### Running the code
Each sub-folder generally contains a `data` folder and a `do` folder:

- The `data` folder is organized into `in` (raw input files) and `out` (processed outputs, figures, and/or intermediate data).
- The `do` folder contains the scripts used for processing and analysis, written in Stata `.do` files or R Markdown `.Rmd` files.

There is no single master script. Instead, users should follow the numbered structure of the folders and run the scripts manually and sequentially. The workflow proceeds from raw data preprocessing to the final outputs used in the paper, including all figures and analyses. The last sub-folder in each main directory contains the analysis scripts that draw on the cleaned datasets produced in earlier steps.


### Raw data
We use publicly available data sourced from the World Bank’s Open Data portal, the Food and Agriculture Organization of the United Nations (FAO) Statistical Database, the Organisation for Economic Co-operation and Development (OECD) Creditor Reporting System (CRS), and AidData.

The specific raw data files used in this study are included in the corresponding `data/in` folders within each subdirectory, with the exception of the CRS dataset. Due to size limitations, the raw CRS dataset used in this study could not be uploaded to this repository. Please refer to the `README` file in the corresponding CRS folder for instructions on how to access and prepare this dataset.

To the best of our knowledge, all datasets are provided under terms that allow redistribution for academic and non-commercial purposes. Please refer to the respective data providers for full terms of use:

- [World Bank’s Open Data portal](https://data360.worldbank.org/en/about)
- [OECD Open Access Policy](https://www.oecd.org/en/about/oecd-open-by-default-policy.html)
- [FAO Statistical Database Terms of Use](https://www.fao.org/contact-us/terms/db-terms-of-use/en/)
- [AidData License](https://github.com/aiddata/gcdf-geospatial-data?tab=License-1-ov-file)


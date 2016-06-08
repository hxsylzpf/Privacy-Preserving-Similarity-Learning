# Privacy Preserving Similarity Learning

## Installation

This project assumes that you already have 'SequentialPhenotypePredictor' repository.
You move two files in 'Data-Generation' folder of this repository into 'DataPrep/mimic' folder of 'SequentialPhenotypePredictor' repository.

## Run

### 1. Data Preparation
To take the code for a spin run the following commands:

    cd DataPrep/mimic
    psql -U mimic -a -f allevents.sql
    python generate_icd_levels.py
    python generate_seq_combined1.py
    python generate_data_matrix1.py

After executing the last command you will see a csv file named 'd_272.csv' in your Data/mimic\_seq folder. Each line in these files represent 1 patient.

### 2. Set Path in Matlab
To run privacy-preserving similarity learning in matlab, set path using the following commands:

    matlab
    addpath('../../Sub-Functions')
    addpath('../../Functions')
    addpath('../../Run-Results')
    savepath ../Run-Results/pathdef.m

### 3. Execution and Results
Run the following commands and you can get several mat files.

    D272
    
Once you obtained mat files, run the following commands to calculate AUCs.

    JH_M
    JH_OC

## Libraries Used

This project depends on:

1. SequentialPhenotypePredictor - https://github.com/wael34218/SequentialPhenotypePredictor

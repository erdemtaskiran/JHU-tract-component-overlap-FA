# JHU White Matter Tract Analysis Script

## Overview
This bash script performs automated analysis of white matter tract overlap with FA (Fractional Anisotropy) masks using the JHU DTI-based white matter atlas. It extracts volumetric measurements, statistical values, and spatial coordinates for specific brain regions of interest.

## Features
- � Analyzes 20 major white matter tracts from the JHU-ICBM atlas
-  Calculates overlap between tract regions and user-defined FA masks
-  Extracts multiple metrics including:
  - Voxel counts and volumes (mm³ and cm³)
  - Overlap percentages
  - Maximum Z-scores from statistical maps
  - Center of gravity (COG) coordinates
-  Outputs results in CSV format for easy analysis

## Requirements
- FSL (FMRIB Software Library)
- zsh shell
- bc calculator

## Usage
1. Configure the paths in the USER CONFIG section:
   - `atlas`: Path to JHU-ICBM tract atlas
   - `mask`: Path to your FA mask
   - `zmap`: Path to your statistical z-map
   - `output`: Desired output CSV filename

2. Run the script:
```bash
./Extract_FA_Values_in_mm3_cm3.sh
```

## Output
The script generates a CSV file containing:
- Tract labels and names
- Voxel counts and volumes
- Overlap statistics
- Maximum Z-values
- Center of gravity coordinates (X, Y, Z)

## Analyzed Tracts
The script analyzes bilateral tracts including:
- Anterior thalamic radiation
- Corticospinal tract
- Cingulum (cingulate gyrus and hippocampus)
- Forceps major and minor
- Inferior fronto-occipital fasciculus
- Inferior and superior longitudinal fasciculus
- Uncinate fasciculus
- Superior longitudinal fasciculus (temporal part)

## Note
This script is designed for neuroimaging research and requires proper understanding of DTI analysis and FSL tools.

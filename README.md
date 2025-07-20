# White Matter Tract Overlap Analysis Script

## Overview
This shell script (`extract_jhu_ic2_fa_pos_fsl_cm3.sh`) performs automated quantitative analysis of white matter tract overlaps using FSL neuroimaging tools. It calculates intersection volumes between functional activation masks and anatomically defined white matter tracts from the Johns Hopkins University (JHU) atlas.

## Prerequisites
- **FSL** (FMRIB Software Library) installed and configured
- **bc** calculator for floating-point arithmetic
- **zsh** shell environment
- JHU white matter tract atlas (included with FSL)

## Input Files Required
1. **Atlas**: `JHU-ICBM-tracts-maxprob-thr0-2mm.nii.gz` - JHU white matter tract atlas
2. **Mask**: Functional activation mask (e.g., `IC2_FA_mask_4.nii.gz`)
3. **Z-map**: Statistical map for extracting maximum Z-values (e.g., `Artist_joint_comp_ica_feature_2_002.nii.gz`)

## Output
CSV file containing detailed overlap metrics for 20 white matter tracts with the following columns:
- **Label**: Tract identifier (0-19)
- **TractName**: Anatomical tract name
- **Voxels**: Number of overlapping voxels
- **Volume_mm3**: Overlap volume in cubic millimeters
- **Volume_cm3**: Overlap volume in cubic centimeters
- **Total_Tract_Voxels**: Total voxels in the complete tract
- **Overlap_Percent**: Percentage of tract showing overlap
- **Max_Z**: Maximum Z-score within overlap region
- **COG_X/Y/Z**: Center of gravity coordinates

## Analyzed White Matter Tracts
The script processes 20 major white matter pathways:

### Projection Tracts
- Anterior thalamic radiation (L/R)
- Corticospinal tract (L/R)

### Association Tracts
- Superior longitudinal fasciculus (L/R)
- Superior longitudinal fasciculus temporal part (L/R)
- Inferior longitudinal fasciculus (L/R)
- Inferior fronto-occipital fasciculus (L/R)
- Uncinate fasciculus (L/R)

### Limbic Tracts
- Cingulum (cingulate gyrus) (L/R)
- Cingulum (hippocampus) (L/R)

### Commissural Tracts
- Forceps major
- Forceps minor

## Algorithm Workflow
1. **Tract Isolation**: Extract individual tract masks from JHU atlas using label-based thresholding
2. **Intersection Calculation**: Multiply tract mask with functional activation mask
3. **Volume Quantification**: Calculate overlap volumes in mm³ and cm³
4. **Statistical Extraction**: Extract maximum Z-scores from overlap regions
5. **Spatial Analysis**: Compute center of gravity coordinates
6. **Cleanup**: Remove intermediate files to save disk space

## Usage
```bash
# Configure paths in the script
atlas="/path/to/JHU-ICBM-tracts-maxprob-thr0-2mm.nii.gz"
mask="/path/to/your_functional_mask.nii.gz"
zmap="/path/to/your_statistical_map.nii.gz"
output="your_output_filename.csv"

# Run the script
chmod +x extract_jhu_ic2_fa_pos_fsl_cm3.sh
./extract_jhu_ic2_fa_pos_fsl_cm3.sh
```

## Key Features
- **Automated Processing**: Batch analysis of all 20 major white matter tracts
- **Comprehensive Metrics**: Volume, percentage overlap, statistical values, and spatial coordinates
- **Memory Efficient**: Cleans up intermediate files during processing
- **Error Handling**: Manages cases with zero overlaps or missing data
- **Standardized Output**: CSV format compatible with statistical software

## FSL Commands Used
- `fslmaths`: Image mathematics and masking operations
- `fslstats`: Statistical analysis and spatial measurements
- Tract isolation: `-thr` and `-uthr` for label-based extraction
- Volume calculation: `-V` flag for voxel count and volume
- Center of gravity: `-C` flag for spatial coordinates
- Statistical extraction: `-R` flag with `-k` masking

## Applications
- **Lesion-deficit mapping**: Quantify white matter damage
- **Functional connectivity**: Structure-function relationships
- **Clinical research**: Track disease progression or treatment effects
- **Comparative studies**: Between-group or longitudinal analyses
- **Quality control**: Validate tractography results

## Technical Notes
- Assumes 2mm isotropic voxels (8mm³ per voxel)
- Uses maximum probability thresholding (thr0)
- Handles bilateral tract analysis with L/R designation
- Compatible with standard MNI152 space
- Outputs volumes in both mm³ and cm³ for convenience


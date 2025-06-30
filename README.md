# JHU-tract-component-overlap-FA
Automated pipeline for quantifying white matter tract involvement in FA nii image using FSL and JHU atlas via FSL
## Purpose

This tool automates the tract-wise quantification of FA nii image spatial distributions in white matter, commonly used in neuroimaging studies investigating:
- White matter network alterations in disease
- Structure-function relationships
- Group-level white matter patterns from tensor-based ICA analyses

## Features

- **Automated tract-wise analysis** of all 20 JHU white matter tracts
- **Comprehensive metrics** including volume, percentage overlap, and peak statistics
- **Flexible thresholding** for positive/negative component maps
- **Clean CSV output** ready for statistical analysis
- **Memory efficient** with automatic cleanup of temporary files
- **Error handling** and validation checks

## Output Metrics

For each tract, the pipeline calculates:
- Voxel count and volume (mm³ and cm³)
- Percentage of tract occupied by component
- Maximum Z-score within overlap region
- Center of gravity coordinates
- Total tract size for reference

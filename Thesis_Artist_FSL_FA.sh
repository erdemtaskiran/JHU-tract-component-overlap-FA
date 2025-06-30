#!/bin/zsh

# ======= USER CONFIG =======
atlas="/Users/erdemtaskiran/fsl/data/atlases/JHU/JHU-ICBM-tracts-maxprob-thr0-2mm.nii.gz"
zmap="/Users/erdemtaskiran/Desktop/Thesis_Artist/Results/tIVA_101_ReHO/FA/Artist_joint_comp_ica_feature_2_002.nii.gz"
output_dir="/Users/erdemtaskiran/Desktop/Thesis_Artist/Results/tIVA_101_ReHO/FA"
output_csv="JHU_IC2_FA_pos_overlap_thr3.5_cm3.csv"

# ======= CREATE MASKS =======
echo "Creating IC2-FA masks..."

# Create positive mask (Z > 3.5)
fslmaths "$zmap" -thr 3.5 -bin "${output_dir}/IC2_FA_pos_mask.nii.gz"

# Create negative mask (Z < -3.5)
fslmaths "$zmap" -uthr -3.5 -bin "${output_dir}/IC2_FA_neg_mask.nii.gz"

# Create combined mask (|Z| > 3.5)
fslmaths "${output_dir}/IC2_FA_pos_mask.nii.gz" -add "${output_dir}/IC2_FA_neg_mask.nii.gz" "${output_dir}/IC2_FA_mask.nii.gz"

# Set which mask to use for analysis
mask="${output_dir}/IC2_FA_pos_mask.nii.gz"  # Using positive mask for this analysis

echo " Masks created successfully"

# ======= CHECK INPUT FILES =======
for file in "$atlas" "$zmap" "$mask"; do
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file"
        exit 1
    fi
done

# Check for required tools
command -v fslmaths >/dev/null 2>&1 || { echo "Error: FSL not found"; exit 1; }
command -v bc >/dev/null 2>&1 || { echo "Error: bc not found"; exit 1; }

# ======= TRACT LABELS =======
tract_names=(
    "Anterior thalamic radiation L"
    "Anterior thalamic radiation R"
    "Corticospinal tract L"
    "Corticospinal tract R"
    "Cingulum (cingulate gyrus) L"
    "Cingulum (cingulate gyrus) R"
    "Cingulum (hippocampus) L"
    "Cingulum (hippocampus) R"
    "Forceps major"
    "Forceps minor"
    "Inferior fronto-occipital fasciculus L"
    "Inferior fronto-occipital fasciculus R"
    "Inferior longitudinal fasciculus L"
    "Inferior longitudinal fasciculus R"
    "Superior longitudinal fasciculus L"
    "Superior longitudinal fasciculus R"
    "Uncinate fasciculus L"
    "Uncinate fasciculus R"
    "SLF (temporal part) L"
    "SLF (temporal part) R"
)

# ======= INIT CSV =======
echo "Label,TractName,Voxels,Volume_mm3,Volume_cm3,Total_Tract_Voxels,Overlap_Percent,Max_Z,COG_X,COG_Y,COG_Z" > "$output_csv"

# ======= PROCESSING LOOP =======
echo "Processing tracts..."

for label in {0..19}
do
    tractname="${tract_names[$label+1]}"
    echo "Processing tract $label: $tractname"
    
    # Create tract binary mask
    if ! fslmaths "$atlas" -thr $label -uthr $label -bin tract_mask_${label}.nii.gz; then
        echo "Error processing tract $label"
        continue
    fi
    
    # Intersect with your positive IC2-FA mask
    fslmaths tract_mask_${label}.nii.gz -mul "$mask" overlap_${label}.nii.gz
    
    # Extract voxel count and volume (mm³)
    read vox vol_mm3 <<< $(fslstats overlap_${label}.nii.gz -V)
    
    # Calculate volume in cm³
    volume_cm3=$(echo "scale=4; $vol_mm3 / 1000" | bc)
    
    # Total voxels in tract
    read t_vox t_vol <<< $(fslstats tract_mask_${label}.nii.gz -V)
    
    # Calculate overlap percent
    if [ "$t_vox" -ne 0 ]; then
        overlap_percent=$(echo "scale=4; $vox / $t_vox * 100" | bc)
    else
        overlap_percent=0
    fi
    
    # Extract Max Z value from original zmap within overlap region
    read minz maxz <<< $(fslstats "$zmap" -k overlap_${label}.nii.gz -R 2>/dev/null)
    if [ -z "$maxz" ]; then
        maxz=0
    fi
    
    # Calculate COG (geometric center of overlap region)
    read cog_x cog_y cog_z <<< $(fslstats overlap_${label}.nii.gz -C 2>/dev/null)
    if [ -z "$cog_x" ]; then
        cog_x=0; cog_y=0; cog_z=0
    fi
    
    # Write to CSV
    echo "$label,\"$tractname\",$vox,$vol_mm3,$volume_cm3,$t_vox,$overlap_percent,$maxz,$cog_x,$cog_y,$cog_z" >> "$output_csv"
    
    # Clean up intermediate files
    rm tract_mask_${label}.nii.gz overlap_${label}.nii.gz
done

echo "✅ Done! Results saved to $output_csv"

# ======= SUMMARY STATS =======
echo ""
echo "Summary of created masks:"
echo "Positive mask (Z > 3.5): ${output_dir}/IC2_FA_pos_mask.nii.gz"
echo "Negative mask (Z < -3.5): ${output_dir}/IC2_FA_neg_mask.nii.gz"
echo "Combined mask (|Z| > 3.5): ${output_dir}/IC2_FA_mask.nii.gz"

# Display mask voxel counts
pos_vox=$(fslstats "${output_dir}/IC2_FA_pos_mask.nii.gz" -V | awk '{print $1}')
neg_vox=$(fslstats "${output_dir}/IC2_FA_neg_mask.nii.gz" -V | awk '{print $1}')
combined_vox=$(fslstats "${output_dir}/IC2_FA_mask.nii.gz" -V | awk '{print $1}')

echo ""
echo "Mask statistics:"
echo "Positive voxels (Z > 3.5): $pos_vox"
echo "Negative voxels (Z < -3.5): $neg_vox"
echo "Combined voxels (|Z| > 3.5): $combined_vox"
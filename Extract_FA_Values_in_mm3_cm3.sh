#!/bin/zsh
# ======= USER CONFIG =======
atlas="/Users/erdemtaskiran/fsl/data/atlases/JHU/JHU-ICBM-tracts-maxprob-thr0-2mm.nii.gz"
mask="/Users/erdemtaskiran/Desktop/jICA/FA/IC2_FA_mask.nii.gz"
zmap="/Users/erdemtaskiran/Desktop/jICA/FA/Artist_joint_comp_ica_feature_2_002.nii.gz"
output="JHU_IC2_FA_pos_overlap_thr4_cm3.csv"

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
echo "Label,TractName,Voxels,Volume_mm3,Volume_cm3,Total_Tract_Voxels,Overlap_Percent,Max_Z,COG_X,COG_Y,COG_Z" > "$output"

# ======= PROCESSING LOOP =======
for label in {0..19}
do
    atlas_label=$((label+1))  # ONLY CHANGE: Extract atlas labels 1-20
    tractname="${tract_names[$label+1]}"
    
    # Create tract binary mask
    fslmaths "$atlas" -thr $atlas_label -uthr $atlas_label -bin tract_mask_${atlas_label}.nii.gz
    
    # Intersect with your positive IC2-FA mask
    fslmaths tract_mask_${atlas_label}.nii.gz -mul "$mask" overlap_${atlas_label}.nii.gz
    
    # Extract voxel count and volume (mm³)
    read vox vol_mm3 <<< $(fslstats overlap_${atlas_label}.nii.gz -V)
    
    # Calculate volume in cm³
    volume_cm3=$(echo "scale=4; $vol_mm3 / 1000" | bc)
    
    # Total voxels in tract
    read t_vox t_vol <<< $(fslstats tract_mask_${atlas_label}.nii.gz -V)
    
    # Calculate overlap percent
    if [ "$t_vox" -ne 0 ]; then
        overlap_percent=$(echo "scale=4; $vox / $t_vox * 100" | bc)
    else
        overlap_percent=0
    fi
    
    # Extract Max Z value
    read minz maxz <<< $(fslstats "$zmap" -k overlap_${atlas_label}.nii.gz -R 2>/dev/null)
    if [ -z "$maxz" ]; then
        maxz=0
    fi
    
    # Calculate COG
    read cog_x cog_y cog_z <<< $(fslstats overlap_${atlas_label}.nii.gz -C 2>/dev/null)
    if [ -z "$cog_x" ]; then
        cog_x=0; cog_y=0; cog_z=0
    fi
    
    # Write to CSV
    echo "$atlas_label,\"$tractname\",$vox,$vol_mm3,$volume_cm3,$t_vox,$overlap_percent,$maxz,$cog_x,$cog_y,$cog_z" >> "$output"
    
    # Clean up intermediate files
    rm tract_mask_${atlas_label}.nii.gz overlap_${atlas_label}.nii.gz
done

echo "✅ Done! Results saved to $output"
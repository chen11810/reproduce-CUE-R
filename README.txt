
Title:
Meta-analysis and Machine Learning Reveal Key Drivers of Microbial Carbon Use Efficiency Under Nitrogen Enrichment

---

## 1. Description

This repository contains the dataset and R code used for the meta-analysis study entitled  
"Meta-analysis and Machine Learning Reveal Key Drivers of Microbial Carbon Use Efficiency Under Nitrogen Enrichment."

The study synthesizes data from multiple peer-reviewed studies to explore the effects of nitrogen addition on soil microbial carbon use efficiency (CUE). Furthermore, it applies a machine learning approach (MetaForest) to identify key environmental and management drivers influencing microbial CUE.

---

## 2. Contents

The repository includes:

- extracted_data.csv – Meta-analysis dataset compiled from published studies  
- analysis_code.R – R script used for data processing, meta-regression, and MetaForest modeling  
- README.txt – This documentation file

---

## 3. Data Description

File: extracted_data.csv

Each row represents a single observation (effect size comparison) derived from a field study on the impact of nitrogen addition on microbial carbon use efficiency (CUE). The dataset includes means, standard deviations, and sample sizes for both nitrogen treatment and control groups, along with environmental moderators.

Variable descriptions:

| Column Name | Description |
|-------------|-------------|
| obs         | Observation ID, unique for each entry |
| Site        | Site code or study identifier |
| Latitude    | Latitude of the study site (decimal degrees) |
| Longitude   | Longitude of the study site (decimal degrees) |
| tm          | Mean microbial CUE in the nitrogen treatment group |
| ts          | Standard deviation of CUE in the treatment group |
| tn          | Sample size of the nitrogen treatment group |
| cm          | Mean microbial CUE in the control group |
| cs          | Standard deviation of CUE in the control group |
| cn          | Sample size of the control group |
| MAP         | Mean Annual Precipitation (mm), grouped variable |
| N_addtion   | Nitrogen addition level (e.g., <100, 100–200, >200 kg N ha⁻¹ yr⁻¹), categorical |
| pH          | Soil pH |
| MAT         | Mean Annual Temperature (°C) |
| SOC         | Soil Organic Carbon content (g kg⁻¹) |
| TN          | Total Nitrogen content in soil (g kg⁻¹) |
| TP          | Total Phosphorus content in soil (g kg⁻¹) |
| CNR         | Carbon-to-nitrogen ratio in soil |
| NPR         | Nitrogen-to-phosphorus ratio in soil |
| MBC         | Microbial biomass carbon (mg kg⁻¹) |
| MBN         | Microbial biomass nitrogen (mg kg⁻¹) |
| MCNR        | Microbial C:N ratio (unitless) |

Missing values are coded as NA.

---

## 4. R Code Instructions

File: analysis_code.R  
Encoding: UTF-8  
Software Requirement: R 4.2.0 or higher

### 📦 Required R Packages:

- tidyverse, meta, metafor, metadat, metaforest, caret, broom, ggplot2, ggspatial, RColorBrewer, ggtext, rcartocolor, ggsci, sf

> Please make sure all packages are installed and up to date before running the script.

### 🧾 Script Overview and Structure:

The script executes the full analytical workflow of the study, including meta-analysis, moderator testing, subgroup comparison, and machine learning analysis.

### 🔹 Step-by-Step Functionality:

1. **Sampling Point Mapping**  
   - Visualizes global distribution of study sites using longitude and latitude data  
   - Output: `Figure 1 Geographic distribution of observational field studies included in the meta-analysis.pdf`

2. **Effect Size Calculation & Forest Plot**  
   - Calculates log response ratios and fits random-effects meta-analysis model  
   - Output: `Figure 2 Forest plot of the effects of nitrogen addition on soil microbial carbon use efficiency.pdf`

3. **Publication Bias Diagnosis**  
   - Generates funnel plot and conducts Egger’s regression test  
   - Output: `Figure S1 Funnel plot with regression test for asymmetry.pdf`

4. **Subgroup & Moderator Analysis**  
   - Conducts meta-regression for precipitation (MAP) and nitrogen addition levels  
   - Output: `Figure 3 Effects of nitrogen addition on soil microbial carbon use efficiency across precipitation and nitrogen addition levels.pdf`  
   - Plus: t-tests comparing subgroup effects

5. **Continuous Moderator Regression**  
   - Meta-regression of continuous variables with prediction intervals and QQ plots  
   - Output: `Figure 4`, `Figure S4` for regression and diagnostic plots

6. **Machine Learning (MetaForest)**  
   - Trains MetaForest model to rank moderators by importance  
   - Performs recursive feature selection, tuning, and partial dependence analysis  
   - Outputs:  
     - `Figure S2_a`, `S2_b`: convergence plots  
     - `Figure S3`: replicated variable importance  
     - `Figure S5`: predicted vs. observed effects  
     - `Figure 5`, `Figure 6`: importance bar chart and PDPs

### ▶️ How to Run

1. Place `analysis_code.R`, `extracted_data.csv`, and `global.shp` in your working directory.
2. Open `analysis_code.R` in RStudio.
3. Run the script step-by-step to generate all figures and outputs.

---

## 5. Citation

If you use this dataset or code, please cite it as:

Yin, T., et al. (2025). Dataset and code for "Meta-analysis and Machine Learning Reveal Key Drivers of Microbial Carbon Use Efficiency Under Nitrogen Enrichment". *Zenodo*. [DOI will be added upon Zenodo release]

---

## 6. License

This repository is licensed under the Creative Commons Attribution 4.0 International (CC BY 4.0) license.

You are free to share and adapt the material for any purpose, even commercially, as long as appropriate credit is given.

---

## 7. Contact

For questions, please contact:  
Tao Yin  
[Qingdao Agricultural University/College of Resources and Environment]  
Email: [yintao@qau.edu.cn]
